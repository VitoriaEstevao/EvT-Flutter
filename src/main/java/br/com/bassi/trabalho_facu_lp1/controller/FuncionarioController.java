package br.com.bassi.trabalho_facu_lp1.controller;

import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos;
import br.com.bassi.trabalho_facu_lp1.dto.FuncionarioDTO;
import br.com.bassi.trabalho_facu_lp1.dto.response.FuncionarioResponseDTO;
import br.com.bassi.trabalho_facu_lp1.service.FuncionarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/funcionarios")
@RequiredArgsConstructor
public class FuncionarioController {

    private final FuncionarioService funcionarioService;

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @GetMapping
    public ResponseEntity<List<FuncionarioResponseDTO>> listarTodos() {
        return ResponseEntity.ok(funcionarioService.listarTodosFuncionarios());
    }

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @GetMapping("/cargo/{cargo}")
    public ResponseEntity<List<FuncionarioResponseDTO>> listarPorCargo(@PathVariable EnumCargos cargo) {
        return ResponseEntity.ok(funcionarioService.listarPorCargo(cargo));
    }

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @PostMapping
    public ResponseEntity<FuncionarioDTO> cadastrarFuncionario(@RequestBody  @Valid FuncionarioDTO dto) {
        FuncionarioDTO novo = funcionarioService.cadastrarFuncionario(dto);
        return ResponseEntity.ok(novo);
    }

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @PutMapping("/{id}")
    public ResponseEntity<FuncionarioDTO> editarFuncionario(@PathVariable Long id, @RequestBody @Valid FuncionarioDTO dto) {
        FuncionarioDTO atualizado = funcionarioService.editarFuncionario(id, dto);
        return ResponseEntity.ok(atualizado);
    }

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluirFuncionario(@PathVariable Long id) {
        funcionarioService.excluirFuncionario(id);
        return ResponseEntity.noContent().build();
    }
}
