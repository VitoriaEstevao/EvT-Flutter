package br.com.bassi.trabalho_facu_lp1.exceptions;

public class CredenciaisInvalidasException extends RuntimeException {
  public CredenciaisInvalidasException(String mensagem) {
    super(mensagem);
  }
}

