//package br.com.bassi.trabalho_facu_lp1.exceptions;
//
//import org.springframework.http.HttpStatus;
//import org.springframework.http.ResponseEntity;
//import org.springframework.web.bind.MethodArgumentNotValidException;
//import org.springframework.web.bind.annotation.ControllerAdvice;
//import org.springframework.web.bind.annotation.ExceptionHandler;
//
//import java.util.HashMap;
//import java.util.Map;
//
//@ControllerAdvice
//public class GlobalExceptionHandler {
//
//    // Trata exceções genéricas
//    @ExceptionHandler(Exception.class)
//    public ResponseEntity<Map<String, String>> handleGeneralException(Exception ex) {
//        Map<String, String> response = new HashMap<>();
//        response.put("message", ex.getMessage());
//        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
//    }
//
//    // Exemplo: trata exceções específicas de validação (DTOs com @Valid)
//    @ExceptionHandler(MethodArgumentNotValidException.class)
//    public ResponseEntity<Map<String, String>> handleValidationException(MethodArgumentNotValidException ex) {
//        Map<String, String> response = new HashMap<>();
//        // Pega a primeira mensagem de erro do campo inválido
//        String errorMessage = ex.getBindingResult().getFieldErrors().stream()
//                .findFirst()
//                .map(error -> error.getDefaultMessage())
//                .orElse("Dados inválidos.");
//        response.put("message", errorMessage);
//        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
//    }
//
//}
