package com.pcs.global.error;

import com.pcs.global.dto.ApiResultDto;
import com.pcs.global.error.exception.BusinessException;
import jakarta.validation.ConstraintViolationException;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResultDto<Void>> handleBusinessException(BusinessException exception) {
        ErrorCode errorCode = exception.getErrorCode();
        return ResponseEntity
                .status(errorCode.getHttpStatus())
                .body(ApiResultDto.error(errorCode, exception.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResultDto<List<ValidationError>>> handleMethodArgumentNotValid(
            MethodArgumentNotValidException exception
    ) {
        List<ValidationError> errors = new ArrayList<>();
        exception.getBindingResult().getFieldErrors()
                .forEach(error -> errors.add(new ValidationError(error.getField(), error.getDefaultMessage())));
        exception.getBindingResult().getGlobalErrors()
                .forEach(error -> errors.add(new ValidationError(error.getObjectName(), error.getDefaultMessage())));

        return ResponseEntity
                .status(ErrorCode.INVALID_INPUT_VALUE.getHttpStatus())
                .body(ApiResultDto.error(ErrorCode.INVALID_INPUT_VALUE, errors));
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiResultDto<List<ValidationError>>> handleConstraintViolation(
            ConstraintViolationException exception
    ) {
        List<ValidationError> errors = exception.getConstraintViolations().stream()
                .map(violation -> new ValidationError(
                        violation.getPropertyPath().toString(),
                        violation.getMessage()
                ))
                .toList();

        return ResponseEntity
                .status(ErrorCode.INVALID_INPUT_VALUE.getHttpStatus())
                .body(ApiResultDto.error(ErrorCode.INVALID_INPUT_VALUE, errors));
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<ApiResultDto<Void>> handleMissingRequestParameter(
            MissingServletRequestParameterException exception
    ) {
        return ResponseEntity
                .status(ErrorCode.MISSING_REQUEST_PARAMETER.getHttpStatus())
                .body(ApiResultDto.error(ErrorCode.MISSING_REQUEST_PARAMETER, exception.getMessage()));
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiResultDto<Void>> handleMethodArgumentTypeMismatch(
            MethodArgumentTypeMismatchException exception
    ) {
        return ResponseEntity
                .status(ErrorCode.INVALID_INPUT_VALUE.getHttpStatus())
                .body(ApiResultDto.error(ErrorCode.INVALID_INPUT_VALUE, exception.getMessage()));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiResultDto<Void>> handleHttpMessageNotReadable(HttpMessageNotReadableException exception) {
        return ResponseEntity
                .status(ErrorCode.INVALID_REQUEST_BODY.getHttpStatus())
                .body(ApiResultDto.error(ErrorCode.INVALID_REQUEST_BODY));
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResultDto<Void>> handleHttpRequestMethodNotSupported(
            HttpRequestMethodNotSupportedException exception
    ) {
        return ResponseEntity
                .status(ErrorCode.UNSUPPORTED_HTTP_METHOD.getHttpStatus())
                .body(ApiResultDto.error(ErrorCode.UNSUPPORTED_HTTP_METHOD));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResultDto<Void>> handleException(Exception exception) {
        log.error("Unhandled exception occurred.", exception);
        return ResponseEntity
                .status(ErrorCode.INTERNAL_SERVER_ERROR.getHttpStatus())
                .body(ApiResultDto.error(ErrorCode.INTERNAL_SERVER_ERROR));
    }

    public record ValidationError(
            String field,
            String message
    ) {
    }
}
