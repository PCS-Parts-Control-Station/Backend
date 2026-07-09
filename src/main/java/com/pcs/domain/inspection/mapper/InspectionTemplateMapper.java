package com.pcs.domain.inspection.mapper;

import com.pcs.domain.inspection.dto.response.InspectionTemplateOptionResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateResponse;
import com.pcs.domain.inspection.dto.response.SearchInspectionTemplateSummaryResponse;
import com.pcs.domain.inspection.entity.InspectionTemplate;
import com.pcs.domain.inspection.entity.InspectionTemplateItem;
import com.pcs.domain.inspection.entity.InspectionTemplateItemOption;
import com.pcs.domain.inspection.type.InspectionItemGroup;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface InspectionTemplateMapper {

    boolean existsCategory(@Param("companyId") Long companyId, @Param("categoryId") Long categoryId);

    List<SearchInspectionTemplateResponse> searchTemplates(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("active") Boolean active,
            @Param("size") int size,
            @Param("offset") int offset
    );

    long countTemplates(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("active") Boolean active
    );

    SearchInspectionTemplateSummaryResponse summarizeTemplates(
            @Param("companyId") Long companyId,
            @Param("keyword") String keyword,
            @Param("categoryId") Long categoryId,
            @Param("active") Boolean active
    );

    InspectionTemplate findTemplateById(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    SearchInspectionTemplateResponse findTemplateSummaryById(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    List<InspectionTemplateItem> findItemsByTemplateId(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    List<InspectionTemplateOptionResponse> findOptionsByTemplateId(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId
    );

    InspectionTemplateItem findItemById(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId
    );

    InspectionTemplateItemOption findOptionById(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId,
            @Param("optionId") Long optionId
    );

    boolean existsTemplateVersion(
            @Param("companyId") Long companyId,
            @Param("categoryId") Long categoryId,
            @Param("templateName") String templateName,
            @Param("version") int version,
            @Param("excludeTemplateId") Long excludeTemplateId
    );

    boolean existsItemName(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemName") String itemName,
            @Param("excludeItemId") Long excludeItemId
    );

    boolean existsOptionLabel(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId,
            @Param("optionLabel") String optionLabel,
            @Param("excludeOptionId") Long excludeOptionId
    );

    boolean existsOptionValue(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId,
            @Param("optionValue") String optionValue,
            @Param("excludeOptionId") Long excludeOptionId
    );

    int nextItemSortOrder(@Param("companyId") Long companyId, @Param("templateId") Long templateId);

    int nextOptionSortOrder(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId
    );

    int countItemsByTemplateGroupAndIds(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemGroup") InspectionItemGroup itemGroup,
            @Param("itemIds") List<Long> itemIds
    );

    int countItemsByTemplateGroup(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemGroup") InspectionItemGroup itemGroup
    );

    int countOptionsByItemIdAndIds(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId,
            @Param("optionIds") List<Long> optionIds
    );

    int countOptionsByItemId(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId
    );

    void insertTemplate(InspectionTemplate template);

    void updateTemplate(InspectionTemplate template);

    int updateTemplateActive(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("active") boolean active
    );

    int touchTemplate(@Param("companyId") Long companyId, @Param("templateId") Long templateId);

    void insertItem(InspectionTemplateItem item);

    void updateItem(@Param("companyId") Long companyId, @Param("item") InspectionTemplateItem item);

    int updateItemActive(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId,
            @Param("active") boolean active
    );

    int updateItemSortOrders(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemGroup") InspectionItemGroup itemGroup,
            @Param("sortOrders") List<SortOrderUpdate> sortOrders
    );

    int deactivateOptionsByItemId(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId
    );

    void insertOption(InspectionTemplateItemOption option);

    void updateOption(@Param("companyId") Long companyId, @Param("templateId") Long templateId, @Param("option") InspectionTemplateItemOption option);

    int updateOptionActive(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId,
            @Param("optionId") Long optionId,
            @Param("active") boolean active
    );

    int updateOptionSortOrders(
            @Param("companyId") Long companyId,
            @Param("templateId") Long templateId,
            @Param("itemId") Long itemId,
            @Param("sortOrders") List<SortOrderUpdate> sortOrders
    );
}
