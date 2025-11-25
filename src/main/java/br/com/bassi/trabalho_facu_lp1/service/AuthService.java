package br.com.bassi.trabalho_facu_lp1.service;

import br.com.bassi.trabalho_facu_lp1.exceptions.CredenciaisInvalidasException;
import br.com.bassi.trabalho_facu_lp1.exceptions.EntidadeNaoEncontradaException;
import br.com.bassi.trabalho_facu_lp1.infra.JwtUtil;
import br.com.bassi.trabalho_facu_lp1.repositories.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder encoder;
    private final JwtUtil jwtUtil;

    public String autenticar(String email, String senha) {
        var usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Credenciais inválidas"));

        if (!encoder.matches(senha, usuario.getSenha())) {
            throw new CredenciaisInvalidasException("Credenciais inválidas");
        }

        return jwtUtil.gerarToken(usuario.getEmail(), usuario.getCargo().name());
    }
}

