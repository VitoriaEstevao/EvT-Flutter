package br.com.bassi.trabalho_facu_lp1.service;

import br.com.bassi.trabalho_facu_lp1.domain.Endereco;
import br.com.bassi.trabalho_facu_lp1.domain.Local;
import br.com.bassi.trabalho_facu_lp1.dto.EnderecoDTO;
import br.com.bassi.trabalho_facu_lp1.dto.LocalDTO;

import br.com.bassi.trabalho_facu_lp1.dto.response.EnderecoResponseDTO;
import br.com.bassi.trabalho_facu_lp1.dto.response.LocalResponseDTO;
import br.com.bassi.trabalho_facu_lp1.exceptions.EntidadeNaoEncontradaException;
import br.com.bassi.trabalho_facu_lp1.exceptions.RegraNegocioException;
import br.com.bassi.trabalho_facu_lp1.repositories.LocalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LocalService {

    private final LocalRepository localRepository;
    private final CepService cepService;

    public LocalDTO criarLocal(LocalDTO localDTO) {

        if (localRepository.existsByNome(localDTO.nome())) {
            throw new RegraNegocioException("Já existe um local com esse nome.");
        }

        Endereco endereco = construirEnderecoCompletado(localDTO.endereco());
        Local local = new Local();
        local.setNome(localDTO.nome());
        local.setCapacidade(localDTO.capacidade());
        local.setEndereco(endereco);

        Local salvo = localRepository.save(local);
        return toLocalDTO(salvo);
    }

    public void deletarLocal(Long id) {
        if (!localRepository.existsById(id)) {
            throw new EntidadeNaoEncontradaException("Local não encontrado para exclusão.");
        }
        localRepository.deleteById(id);
    }

    public Optional<LocalResponseDTO> buscarLocal(Long id) {
        return localRepository.findById(id)
                .map(this::toLocalResponseDTO);
    }

    public List<LocalResponseDTO> listarLocais() {
        return localRepository.findAll()
                .stream()
                .map(this::toLocalResponseDTO)
                .collect(Collectors.toList());
    }

    public LocalDTO editarLocal(Long id, LocalDTO localDTO) {
        return localRepository.findById(id)
                .map(local -> {
                    if (localRepository.existsByNome(localDTO.nome()) &&
                            !local.getNome().equalsIgnoreCase(localDTO.nome())) {
                        throw new RegraNegocioException("Já existe outro local com esse nome.");
                    }

                    Endereco endereco = construirEnderecoCompletado(localDTO.endereco());

                    local.setNome(localDTO.nome());
                    local.setCapacidade(localDTO.capacidade());
                    local.setEndereco(endereco);

                    Local atualizado = localRepository.save(local);
                    return toLocalDTO(atualizado);
                })
                .orElseThrow(() -> new EntidadeNaoEncontradaException("Local não encontrado."));
    }


    private Endereco construirEnderecoCompletado(EnderecoDTO dto) {
        var viaCep = cepService.buscarPorCep(dto.cep());

        if (viaCep == null || viaCep.logradouro() == null) {
            throw new RegraNegocioException("CEP inválido ou não encontrado.");
        }

        return new Endereco(
                viaCep.logradouro(),
                viaCep.bairro(),
                viaCep.localidade(),
                viaCep.uf(),
                dto.numero(),
                dto.cep()
        );
    }




    private LocalDTO toLocalDTO(Local local) {
        return new LocalDTO(
                local.getNome(),
                new EnderecoDTO(
                        local.getEndereco().getCep(),
                        local.getEndereco().getNumero()
                ),
                local.getCapacidade()
        );
    }


    private LocalResponseDTO toLocalResponseDTO(Local local) {
        return new LocalResponseDTO(
                local.getId(),
                local.getNome(),
                new EnderecoResponseDTO(
                        local.getEndereco().getRua(),
                        local.getEndereco().getBairro(),
                        local.getEndereco().getCidade(),
                        local.getEndereco().getEstado(),
                        local.getEndereco().getNumero(),
                        local.getEndereco().getCep()
                ),
                local.getCapacidade()
        );
    }

}
