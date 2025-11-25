package br.com.bassi.trabalho_facu_lp1.dto.response;

public record EnderecoResponseDTO(
        String rua,
        String bairro,
        String cidade,
        String estado,
        Integer numero,
        String cep
) {}
