package br.com.bassi.trabalho_facu_lp1.dto.response;

import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos;
import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumDepartamento;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record FuncionarioResponseDTO(
        Long id,

        @NotBlank(message = "O nome é obrigatório")
        String nome,

        @NotBlank(message = "O email é obrigatório")
        @Email(message = "Informe um email válido.")
        String email,

        @NotBlank(message = "O cpf é obrigatório")
        @Pattern(regexp = "\\d{11}", message = "O CPF deve conter 11 dígitos numéricos.")
        String cpf,


        @NotBlank(message = "O cargo é obrigatório")
        EnumCargos cargo,

        @NotBlank(message = "O departamenento é obrigatório")
        EnumDepartamento departamento
) {}