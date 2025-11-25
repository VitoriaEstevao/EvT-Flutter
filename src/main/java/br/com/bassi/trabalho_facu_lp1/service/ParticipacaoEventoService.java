package br.com.bassi.trabalho_facu_lp1.service;

import br.com.bassi.trabalho_facu_lp1.domain.Evento;
import br.com.bassi.trabalho_facu_lp1.domain.ParticipacaoEvento;
import br.com.bassi.trabalho_facu_lp1.domain.Usuario;
import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumEstadoEvento;
import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumTipoEvento;
import br.com.bassi.trabalho_facu_lp1.dto.ParticipacaoEventoDTO;
import br.com.bassi.trabalho_facu_lp1.dto.FuncionarioDTO;
import br.com.bassi.trabalho_facu_lp1.exceptions.EntidadeNaoEncontradaException;
import br.com.bassi.trabalho_facu_lp1.exceptions.RegraNegocioException;
import br.com.bassi.trabalho_facu_lp1.repositories.EventoRepository;
import br.com.bassi.trabalho_facu_lp1.repositories.ParticipacaoEventoRepository;
import br.com.bassi.trabalho_facu_lp1.repositories.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class    ParticipacaoEventoService {

    private final EventoRepository eventoRepository;
    private final ParticipacaoEventoRepository participacaoEventoRepository;
    private final UsuarioRepository usuarioRepository;

    public void adicionarParticipante(ParticipacaoEventoDTO dto) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Usuário autenticado não encontrado."));

        Evento evento = eventoRepository.findByTitulo(dto.tituloEvento())
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Evento não encontrado com nome: " + dto.tituloEvento()));


        boolean jaParticipando = participacaoEventoRepository.findByUsuarioId(usuario)
                .stream()
                .anyMatch(p -> p.getEventoId().equals(evento));

        if (jaParticipando) {
            throw new RegraNegocioException("Você já está inscrito neste evento.");
        }

        if (evento.getEstadoEvento() == EnumEstadoEvento.FECHADO) {
            throw new RegraNegocioException("Não é possível se inscrever em um evento fechado.");
        }

        if (evento.getVagas() <= 0) {
            evento.setEstadoEvento(EnumEstadoEvento.FECHADO);
            eventoRepository.save(evento);
            throw new RegraNegocioException("Evento sem vagas disponíveis.");
        }

        ParticipacaoEvento participacao = new ParticipacaoEvento();
        participacao.setEventoId(evento);
        participacao.setUsuarioId(usuario);
        participacaoEventoRepository.save(participacao);

        evento.setVagas(evento.getVagas() - 1);

        if (evento.getTipoEvento() != EnumTipoEvento.REMOTO && evento.getLocal() != null) {
            int capacidade = evento.getLocal().getCapacidade();
            if (evento.getVagas() <= 0 || evento.getVagas() >= capacidade) {
                evento.setEstadoEvento(EnumEstadoEvento.FECHADO);
            }
        }

        eventoRepository.save(evento);
    }


    public List<Evento> listarEventosDoUsuarioLogado() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();

        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Usuário autenticado não encontrado."));

        return participacaoEventoRepository.findByUsuarioId(usuario)
                .stream()
                .map(ParticipacaoEvento::getEventoId)
                .collect(Collectors.toList());
    }

    public List<FuncionarioDTO> listarUsuariosPorEvento(Long eventoId) {
        Evento evento = eventoRepository.findById(eventoId)
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Evento não encontrado com ID: " + eventoId));

        List<Usuario> usuarios = participacaoEventoRepository.findByEventoId(evento)
                .stream()
                .map(ParticipacaoEvento::getUsuarioId)
                .collect(Collectors.toList());

        return usuarios.stream()
                .map(usuario -> new FuncionarioDTO(
                        usuario.getNome(),
                        usuario.getEmail(),
                        usuario.getSenha(),
                        usuario.getCpf(),
                        usuario.getCargo(),
                        usuario.getDepartamento()
                ))
                .collect(Collectors.toList());
    }

}
