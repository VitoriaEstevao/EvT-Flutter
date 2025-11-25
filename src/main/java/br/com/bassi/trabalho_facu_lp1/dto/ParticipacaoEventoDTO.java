package br.com.bassi.trabalho_facu_lp1.dto;

import jakarta.validation.constraints.NotBlank;

public record ParticipacaoEventoDTO(

        @NotBlank(message = "O título do evento é obrigatório.")
        String tituloEvento) {}



