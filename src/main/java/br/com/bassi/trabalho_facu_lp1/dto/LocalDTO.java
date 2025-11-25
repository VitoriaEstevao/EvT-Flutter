package br.com.bassi.trabalho_facu_lp1.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record LocalDTO(
        @NotBlank(message = "O nome é obrigatório.")
        String nome,

        @NotNull(message = "O endereço é obrigatório.")
        @Valid
        EnderecoDTO endereco,

        @NotNull(message = "A capacidade é obrigatória.")
        @Min(value = 1, message = "A capacidade deve ser maior que zero.")
        Integer capacidade
) {}
