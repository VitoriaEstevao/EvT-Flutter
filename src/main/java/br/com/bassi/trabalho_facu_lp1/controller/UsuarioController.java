package br.com.bassi.trabalho_facu_lp1.controller;

import br.com.bassi.trabalho_facu_lp1.dto.UsuarioDTO;
import br.com.bassi.trabalho_facu_lp1.dto.response.UsuarioResponseDTO;
import br.com.bassi.trabalho_facu_lp1.service.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @GetMapping
    public ResponseEntity<List<UsuarioResponseDTO>> listarTodos() {
        return ResponseEntity.ok(usuarioService.listarTodos());
    }

    @PostMapping
    public ResponseEntity<UsuarioDTO> cadastrarUsuario(@RequestBody @Valid UsuarioDTO dto) {
        UsuarioDTO novo = usuarioService.cadastrarUsuario(dto);
        return ResponseEntity.ok(novo);
    }

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @PutMapping("/{id}")
    public ResponseEntity<UsuarioDTO> editarUsuario(@PathVariable Long id, @RequestBody @Valid UsuarioDTO dto) {
        UsuarioDTO atualizado = usuarioService.editarUsuario(id, dto);
        return ResponseEntity.ok(atualizado);
    }

    @PreAuthorize("hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).GERENTE.name())")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluirUsuario(@PathVariable Long id) {
        usuarioService.excluirUsuario(id);
        return ResponseEntity.noContent().build();
    }
}
