package br.com.bassi.trabalho_facu_lp1.service;

import br.com.bassi.trabalho_facu_lp1.domain.Evento;
import br.com.bassi.trabalho_facu_lp1.domain.Local;
import br.com.bassi.trabalho_facu_lp1.domain.Usuario;
import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumEstadoEvento;
import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumTipoEvento;
import br.com.bassi.trabalho_facu_lp1.dto.EventoDTO;
import br.com.bassi.trabalho_facu_lp1.dto.response.EventoResponseDTO;
import br.com.bassi.trabalho_facu_lp1.exceptions.EmailJaCadastradoException;
import br.com.bassi.trabalho_facu_lp1.exceptions.EntidadeNaoEncontradaException;
import br.com.bassi.trabalho_facu_lp1.exceptions.RegraNegocioException;
import br.com.bassi.trabalho_facu_lp1.exceptions.TituloJaCadastradoException;
import br.com.bassi.trabalho_facu_lp1.repositories.EventoRepository;
import br.com.bassi.trabalho_facu_lp1.repositories.LocalRepository;
import br.com.bassi.trabalho_facu_lp1.repositories.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class EventoService {

    private final EventoRepository eventoRepository;
    private final LocalRepository localRepository;
    private final UsuarioRepository usuarioRepository;

    public EventoDTO criarEvento(EventoDTO dto) {
        Evento evento = construirEvento(dto);
        Evento salvo = eventoRepository.save(evento);
        return toEventoDTO(salvo);
    }

    public void deletarEvento(Long id) {
        eventoRepository.deleteById(id);
    }

    public Optional<EventoResponseDTO> buscarEvento(Long id) {
        return eventoRepository.findById(id)
                .map(this::atualizarEstadoSeNecessario)
                .map(this::toEventoResponseDTO);
    }

    public List<EventoResponseDTO> listarEventos() {
        return eventoRepository.findAll()
                .stream()
                .map(this::atualizarEstadoSeNecessario)
                .map(this::toEventoResponseDTO)
                .collect(Collectors.toList());
    }

    public EventoDTO editarEvento(Long id, EventoDTO dto) {
        return eventoRepository.findById(id)
                .map(evento -> {
                    if (evento.getEstadoEvento() == EnumEstadoEvento.FECHADO) {
                        throw new RegraNegocioException("Evento já foi fechado e não pode ser alterado.");
                    }

                    evento.setData(dto.data());
                    evento.setTitulo(dto.titulo());
                    evento.setDescricao(dto.descricao());
                    evento.setVagas(dto.vagas());
                    evento.setTipoEvento(dto.tipoEvento());

                    if (dto.data().before(new Date())) {
                        evento.setEstadoEvento(EnumEstadoEvento.FECHADO);
                    } else {
                        evento.setEstadoEvento(dto.estadoEvento() != null ? dto.estadoEvento() : EnumEstadoEvento.ABERTO);
                    }

                    if (eventoRepository.existsByTituloAndIdNot(dto.titulo(),id)) {
                        throw new TituloJaCadastradoException("Titulo já cadastrado!");
                    }

                    if (dto.palestranteId() != null) {
                        Usuario palestrante = usuarioRepository.findById(dto.palestranteId())
                                .orElseThrow(() -> new EntidadeNaoEncontradaException("Palestrante não encontrado"));
                        evento.setPalestrante(palestrante);
                    }

                    if (dto.tipoEvento() == EnumTipoEvento.REMOTO) {
                        evento.setLocal(null);
                    } else if (dto.localId() != null) {
                        Local local = localRepository.findById(dto.localId())
                                .orElseThrow(() -> new EntidadeNaoEncontradaException("Local não encontrado"));


                        if (dto.vagas() > local.getCapacidade()) {
                            throw new RegraNegocioException("Número de vagas não pode ser maior que a capacidade do local (" + local.getCapacidade() + ").");
                        }

                        evento.setLocal(local);
                    }

                    Evento atualizado = eventoRepository.save(evento);
                    return toEventoDTO(atualizado);
                })
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Evento não encontrado"));
    }

    private Evento construirEvento(EventoDTO dto) {
        Evento evento = new Evento();

        evento.setData(dto.data());
        evento.setTitulo(dto.titulo());
        evento.setDescricao(dto.descricao());
        evento.setVagas(dto.vagas());
        evento.setTipoEvento(dto.tipoEvento());


        if (dto.data().before(new Date())) {
            evento.setEstadoEvento(EnumEstadoEvento.FECHADO);
        } else {
            evento.setEstadoEvento(dto.estadoEvento() != null ? dto.estadoEvento() : EnumEstadoEvento.ABERTO);
        }
        if (eventoRepository.existsByTitulo(dto.titulo())) {
            throw new TituloJaCadastradoException("Titulo já cadastrado!");
        }



            if (dto.tipoEvento() != EnumTipoEvento.REMOTO) {
            if (dto.localId() == null) {
                throw new RegraNegocioException("O local é obrigatório para eventos presenciais.");
            }

            Local local = localRepository.findById(dto.localId())
                    .orElseThrow(() -> new EntidadeNaoEncontradaException("Local não encontrado"));


            if (dto.vagas() > local.getCapacidade()) {
                throw new RegraNegocioException("Não é possível criar um evento com mais vagas (" + dto.vagas()
                        + ") do que a capacidade do local (" + local.getCapacidade() + ").");
            }

            evento.setLocal(local);
        }


        if (dto.palestranteId() != null) {
            Usuario palestrante = usuarioRepository.findById(dto.palestranteId())
                    .orElseThrow(() -> new EntidadeNaoEncontradaException("Palestrante não encontrado"));
            evento.setPalestrante(palestrante);
        }

        return evento;
    }

    private Evento atualizarEstadoSeNecessario(Evento evento) {
        if (evento.getData().before(new Date()) && evento.getEstadoEvento() != EnumEstadoEvento.FECHADO) {
            evento.setEstadoEvento(EnumEstadoEvento.FECHADO);
            eventoRepository.save(evento);
        }
        return evento;
    }


    private EventoDTO toEventoDTO(Evento evento) {
        return new EventoDTO(
                evento.getLocal() != null ? evento.getLocal().getId() : null,
                evento.getEstadoEvento(),
                evento.getTipoEvento(),
                evento.getData(),
                evento.getTitulo(),
                evento.getDescricao(),
                evento.getVagas(),
                evento.getPalestrante() != null ? evento.getPalestrante().getId() : null
        );
    }

    private EventoResponseDTO toEventoResponseDTO(Evento evento) {
        return new EventoResponseDTO(
                evento.getId(),
                evento.getLocal() != null ? evento.getLocal().getId() : null,
                evento.getEstadoEvento(),
                evento.getTipoEvento(),
                evento.getData(),
                evento.getTitulo(),
                evento.getDescricao(),
                evento.getVagas(),
                evento.getPalestrante() != null ? evento.getPalestrante().getId() : null
        );
    }
}
