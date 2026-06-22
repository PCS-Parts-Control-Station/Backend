package com.pcs.domain.member.service;

import com.pcs.domain.member.dto.request.ChangeMypagePasswordRequest;
import com.pcs.domain.member.dto.request.CreateMemberRequest;
import com.pcs.domain.member.dto.request.UpdateMypageRequest;
import com.pcs.domain.member.dto.request.UpdateMemberRequest;
import com.pcs.domain.member.dto.response.CreateMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberResponse;
import com.pcs.domain.member.dto.response.SearchMemberSummaryResponse;
import com.pcs.domain.member.dto.response.TemporaryPasswordResponse;
import com.pcs.domain.member.entity.Member;
import com.pcs.domain.member.entity.MemberAccount;
import com.pcs.domain.member.mapper.MemberMapper;
import com.pcs.domain.member.type.MemberRole;
import com.pcs.domain.member.type.PasswordStatus;
import com.pcs.global.dto.PageResultDto;
import com.pcs.global.error.ErrorCode;
import com.pcs.global.error.exception.BusinessException;
import com.pcs.global.pagination.PageQuery;
import com.pcs.global.util.TextNormalizer;
import com.pcs.global.workspace.WorkspaceAccessValidator;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemberService {

    private static final int OWNER_SLOT = 1;
    private static final int DEFAULT_SIZE = 10;
    private static final int TEMP_PASSWORD_EXPIRE_DAYS = 7;
    private static final char[] TEMP_PASSWORD_CHARS =
            "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789".toCharArray();

    private final MemberMapper memberMapper;
    private final PasswordEncoder passwordEncoder;
    private final WorkspaceAccessValidator workspaceAccessValidator;
    private final SecureRandom secureRandom = new SecureRandom();

    public MemberService(
            MemberMapper memberMapper,
            PasswordEncoder passwordEncoder,
            WorkspaceAccessValidator workspaceAccessValidator
    ) {
        this.memberMapper = memberMapper;
        this.passwordEncoder = passwordEncoder;
        this.workspaceAccessValidator = workspaceAccessValidator;
    }

    @Transactional
    public OwnerMemberCreationResult createOwner(Long companyId, String loginId, String name, String rawPassword) {
        Member owner = new Member(
                companyId,
                loginId,
                passwordEncoder.encode(rawPassword),
                name,
                MemberRole.OWNER,
                OWNER_SLOT,
                PasswordStatus.ACTIVE,
                null,
                null
        );
        memberMapper.insert(owner);
        return new OwnerMemberCreationResult(owner.getMemberId(), owner.getLoginId());
    }

    public PageResultDto<SearchMemberResponse, SearchMemberSummaryResponse> searchMembers(
            Long companyId,
            MemberRole actorRole,
            String keyword,
            MemberRole requestedRole,
            Integer page,
            Integer size,
            Integer limit
    ) {
        validateCompanyActive(companyId);
        List<MemberRole> manageableRoles = manageableRoles(actorRole);
        validateRequestedRole(requestedRole, manageableRoles);

        String normalizedKeyword = TextNormalizer.optional(keyword);
        PageQuery pageQuery = PageQuery.of(page, size, limit, DEFAULT_SIZE);
        long totalElements = memberMapper.countMembers(
                companyId,
                normalizedKeyword,
                requestedRole,
                manageableRoles
        );
        List<SearchMemberResponse> items = totalElements == 0
                ? List.of()
                : memberMapper.searchMembers(
                        companyId,
                        normalizedKeyword,
                        requestedRole,
                        manageableRoles,
                        pageQuery.size(),
                        pageQuery.offset()
                );
        SearchMemberSummaryResponse summary = memberMapper.summarizeMembers(
                companyId,
                normalizedKeyword,
                requestedRole,
                manageableRoles
        );
        return PageResultDto.of(items, pageQuery.page(), pageQuery.size(), totalElements, summary);
    }

    @Transactional
    public CreateMemberResponse createMember(
            Long companyId,
            Long createdBy,
            MemberRole actorRole,
            CreateMemberRequest request
    ) {
        validateCompanyActive(companyId);
        List<MemberRole> manageableRoles = manageableRoles(actorRole);
        validateRequestedRole(request.role(), manageableRoles);

        String loginId = TextNormalizer.required(request.loginId());
        String memberName = TextNormalizer.required(request.memberName());
        if (memberMapper.existsByLoginId(companyId, loginId)) {
            throw new BusinessException(ErrorCode.MEMBER_LOGIN_ID_DUPLICATED);
        }

        LocalDateTime expiresAt = LocalDateTime.now().plusDays(TEMP_PASSWORD_EXPIRE_DAYS);
        String temporaryPassword = generateTemporaryPassword();
        Member member = new Member(
                companyId,
                loginId,
                passwordEncoder.encode(temporaryPassword),
                memberName,
                request.role(),
                null,
                PasswordStatus.TEMPORARY,
                expiresAt,
                createdBy
        );
        memberMapper.insert(member);
        return new CreateMemberResponse(
                findManagedMember(companyId, actorRole, member.getMemberId()),
                temporaryPassword,
                expiresAt
        );
    }

    public SearchMemberResponse getMember(Long companyId, MemberRole actorRole, Long memberId) {
        validateCompanyActive(companyId);
        return findManagedMember(companyId, actorRole, memberId);
    }

    @Transactional
    public SearchMemberResponse updateMember(
            Long companyId,
            MemberRole actorRole,
            Long memberId,
            UpdateMemberRequest request
    ) {
        validateCompanyActive(companyId);
        SearchMemberResponse target = findManagedMember(companyId, actorRole, memberId);
        List<MemberRole> manageableRoles = manageableRoles(actorRole);
        validateRequestedRole(request.role(), manageableRoles);

        String memberName = TextNormalizer.required(request.memberName());
        memberMapper.updateMember(companyId, target.memberId(), memberName, request.role());
        return findManagedMember(companyId, actorRole, memberId);
    }

    @Transactional
    public TemporaryPasswordResponse issueTemporaryPassword(Long companyId, MemberRole actorRole, Long memberId) {
        validateCompanyActive(companyId);
        SearchMemberResponse target = findManagedMember(companyId, actorRole, memberId);
        String temporaryPassword = generateTemporaryPassword();
        LocalDateTime expiresAt = LocalDateTime.now().plusDays(TEMP_PASSWORD_EXPIRE_DAYS);
        int updatedCount = memberMapper.updateTemporaryPassword(
                companyId,
                target.memberId(),
                passwordEncoder.encode(temporaryPassword),
                expiresAt
        );
        if (updatedCount == 0) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_FOUND);
        }
        return new TemporaryPasswordResponse(temporaryPassword, expiresAt);
    }

    public MemberAccount getMyAccount(Long companyId, Long memberId) {
        validateCompanyActive(companyId);
        MemberAccount account = memberMapper.findAccount(companyId, memberId);
        if (account == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_FOUND);
        }
        if (Boolean.FALSE.equals(account.getActive())) {
            throw new BusinessException(ErrorCode.MEMBER_INACTIVE);
        }
        return account;
    }

    @Transactional
    public MemberAccount updateMyAccount(Long companyId, Long memberId, UpdateMypageRequest request) {
        validateCompanyActive(companyId);
        String name = TextNormalizer.required(request.name());
        int updatedCount = memberMapper.updateMypageName(companyId, memberId, name);
        if (updatedCount == 0) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_FOUND);
        }
        return getMyAccount(companyId, memberId);
    }

    @Transactional
    public MemberAccount changeMyPassword(Long companyId, Long memberId, ChangeMypagePasswordRequest request) {
        validateCompanyActive(companyId);
        MemberAccount account = getMyAccount(companyId, memberId);
        if (!passwordEncoder.matches(request.currentPassword(), account.getPasswordHash())) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "현재 비밀번호가 올바르지 않습니다.");
        }
        if (!request.newPassword().equals(request.newPasswordConfirm())) {
            throw new BusinessException(ErrorCode.INVALID_INPUT_VALUE, "새 비밀번호 확인이 일치하지 않습니다.");
        }

        String passwordHash = passwordEncoder.encode(request.newPassword());
        int updatedCount = memberMapper.updateMypagePassword(companyId, memberId, passwordHash);
        if (updatedCount == 0) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_FOUND);
        }
        return getMyAccount(companyId, memberId);
    }

    private SearchMemberResponse findManagedMember(Long companyId, MemberRole actorRole, Long memberId) {
        SearchMemberResponse target = memberMapper.findResponseById(companyId, memberId);
        if (target == null) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_FOUND);
        }
        if (!manageableRoles(actorRole).contains(target.role())) {
            throw new BusinessException(ErrorCode.AUTH_FORBIDDEN);
        }
        return target;
    }

    private void validateRequestedRole(MemberRole requestedRole, List<MemberRole> manageableRoles) {
        if (requestedRole != null && !manageableRoles.contains(requestedRole)) {
            throw new BusinessException(ErrorCode.AUTH_FORBIDDEN);
        }
    }

    private List<MemberRole> manageableRoles(MemberRole actorRole) {
        if (actorRole == MemberRole.OWNER) {
            return List.of(MemberRole.ADMIN, MemberRole.STAFF);
        }
        if (actorRole == MemberRole.ADMIN) {
            return List.of(MemberRole.STAFF);
        }
        throw new BusinessException(ErrorCode.AUTH_FORBIDDEN);
    }

    private void validateCompanyActive(Long companyId) {
        workspaceAccessValidator.validateCompanyActive(companyId);
    }

    private String generateTemporaryPassword() {
        StringBuilder password = new StringBuilder("PCS-");
        for (int index = 0; index < 10; index++) {
            password.append(TEMP_PASSWORD_CHARS[secureRandom.nextInt(TEMP_PASSWORD_CHARS.length)]);
        }
        return password.toString();
    }
}
