package br.com.bassi.trabalho_facu_lp1.controller;

import br.com.bassi.trabalho_facu_lp1.dto.EventoDTO;
import br.com.bassi.trabalho_facu_lp1.dto.response.EventoResponseDTO;
import br.com.bassi.trabalho_facu_lp1.service.EventoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;


import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/eventos")
@RequiredArgsConstructor
public class EventoController {

    private final EventoService eventoService;

    @PreAuthorize("!hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).VISITANTE.name())")
    @PostMapping
    public ResponseEntity<EventoDTO> criarEvento(@RequestBody @Valid EventoDTO eventoDTO) {
        var criado = eventoService.criarEvento(eventoDTO);
        String encodedTitle = URLEncoder.encode(criado.titulo(), StandardCharsets.UTF_8);
        URI uri = URI.create("/eventos/" + encodedTitle);
        return ResponseEntity.created(uri).body(criado);
    }

    @GetMapping
    public ResponseEntity<List<EventoResponseDTO>> listarEventos() {
        return ResponseEntity.ok(eventoService.listarEventos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventoResponseDTO> buscarEvento(@PathVariable Long id) {
        return eventoService.buscarEvento(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("!hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).VISITANTE.name())")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletarEvento(@PathVariable Long id) {
        eventoService.deletarEvento(id);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("!hasAuthority(T(br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos).VISITANTE.name())")
    @PutMapping("/{id}")
    public ResponseEntity<EventoDTO> editarEvento(@PathVariable Long id, @RequestBody @Valid EventoDTO eventoDTO) {
        var att = eventoService.editarEvento(id, eventoDTO);
        return ResponseEntity.ok(att);
    }
}
