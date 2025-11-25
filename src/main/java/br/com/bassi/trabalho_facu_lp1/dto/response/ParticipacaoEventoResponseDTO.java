package br.com.bassi.trabalho_facu_lp1.dto.response;

import jakarta.validation.constraints.NotBlank;

public record ParticipacaoEventoResponseDTO(
        @NotBlank(message = "O cpf do usuário é obrigatório.")
        String cpfUsuario,

        @NotBlank(message = "O título do evento é obrigatório.")
        String tituloEvento) {}
