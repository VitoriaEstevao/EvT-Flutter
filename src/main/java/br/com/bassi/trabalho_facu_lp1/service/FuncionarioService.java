package br.com.bassi.trabalho_facu_lp1.service;

import br.com.bassi.trabalho_facu_lp1.domain.Usuario;
import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumCargos;
import br.com.bassi.trabalho_facu_lp1.dto.FuncionarioDTO;
import br.com.bassi.trabalho_facu_lp1.dto.response.FuncionarioResponseDTO;
import br.com.bassi.trabalho_facu_lp1.exceptions.CpfJaCadastradoException;
import br.com.bassi.trabalho_facu_lp1.exceptions.EmailJaCadastradoException;
import br.com.bassi.trabalho_facu_lp1.exceptions.EntidadeNaoEncontradaException;
import br.com.bassi.trabalho_facu_lp1.repositories.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FuncionarioService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public FuncionarioDTO cadastrarFuncionario(FuncionarioDTO dto) {
        if (usuarioRepository.existsByEmail(dto.email())) {
            throw new EmailJaCadastradoException("E-mail já cadastrado!");
        }
        if (usuarioRepository.existsByCpf(dto.cpf())) {
            throw new CpfJaCadastradoException("CPF já cadastrado!");
        }

        Usuario usuario = toEntity(dto);
        usuario.setSenha(passwordEncoder.encode(dto.senha()));
        usuarioRepository.save(usuario);
        return dto;
    }

    public FuncionarioDTO editarFuncionario(Long id, FuncionarioDTO dto) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Funcionário não encontrado"));

        usuario.setNome(dto.nome());
        usuario.setEmail(dto.email());
        usuario.setCpf(dto.cpf());
        usuario.setCargo(dto.cargo());
        usuario.setDepartamento(dto.departamento());
        if (usuarioRepository.existsByEmailAndIdNot(dto.email(), id)) {
            throw new EmailJaCadastradoException("E-mail já cadastrado");
        }

        if (usuarioRepository.existsByCpfAndIdNot(dto.cpf(), id)) {
            throw new CpfJaCadastradoException("CPF já cadastrado");
        }
        if (dto.senha() != null && !dto.senha().isEmpty()) {
            usuario.setSenha(passwordEncoder.encode(dto.senha()));
        }

        usuarioRepository.save(usuario);
        return dto;
    }

    public List<FuncionarioResponseDTO> listarTodosFuncionarios() {
        return usuarioRepository.findAll().stream()
                .filter(u -> u.getCargo() != EnumCargos.VISITANTE)
                .map(this::toResponseDTO)
                .toList();
    }

    public List<FuncionarioResponseDTO> listarPorCargo(EnumCargos cargo) {
        return usuarioRepository.findByCargo(cargo).stream()
                .map(this::toResponseDTO)
                .toList();
    }

    public void excluirFuncionario(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Funcionário não encontrado"));

        usuarioRepository.deleteById(id);
    }

    private Usuario toEntity(FuncionarioDTO dto) {
        Usuario usuario = new Usuario();
        usuario.setNome(dto.nome());
        usuario.setEmail(dto.email());
        usuario.setSenha(dto.senha());
        usuario.setCpf(dto.cpf());
        usuario.setCargo(dto.cargo());
        usuario.setDepartamento(dto.departamento());
        return usuario;
    }

    private FuncionarioResponseDTO toResponseDTO(Usuario usuario) {
        return new FuncionarioResponseDTO(
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                usuario.getCpf(),
                usuario.getCargo(),
                usuario.getDepartamento()
        );
    }
}






