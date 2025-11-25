package br.com.bassi.trabalho_facu_lp1.domain;

import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumEstadoEvento;
import br.com.bassi.trabalho_facu_lp1.domain.enuns.EnumTipoEvento;
import jakarta.persistence.*;
import lombok.*;
import java.util.Date;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = "id")
@Entity(name = "Evento")
@Table(name = "eventos")
public class Evento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EnumTipoEvento tipoEvento;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EnumEstadoEvento estadoEvento;

    @Column(nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date data;

    private String descricao;

    @Column(unique = true, nullable = false)
    private String titulo;

    @Column(nullable = false)
    private Integer vagas;

    @ManyToOne
    @JoinColumn(name = "local_id")
    private Local local;

    @ManyToOne
    @JoinColumn(name = "palestrante_id")
    private Usuario palestrante;


}
