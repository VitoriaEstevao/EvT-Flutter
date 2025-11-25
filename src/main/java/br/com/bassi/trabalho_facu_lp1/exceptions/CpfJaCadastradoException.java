package br.com.bassi.trabalho_facu_lp1.exceptions;

public class CpfJaCadastradoException extends RuntimeException {
    public CpfJaCadastradoException(String mensagem) {
        super(mensagem);
    }
}