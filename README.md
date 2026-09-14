# Guardiões da Floresta

Jogo 2D em Godot 4.7.2. Prólogo: biblioteca, livro misterioso, portal e encontro com o Espírito da Sumaúma. A floresta usa cenários vistos de frente, com movimento apenas para esquerda e direita (sem salto). Na biblioteca, o movimento continua nas quatro direções. Diálogos somente em texto; música contínua e baixa durante o jogo.

## Abrir em outro computador

1. Instale Git e Godot 4.7.2 e entre na sua conta do GitHub.
2. Clone o repositório privado:
   `git clone https://github.com/devcapivara1459-ctrl/guardioes-da-floresta.git`
3. No Godot, importe o arquivo `project.godot` da pasta clonada. Aguarde a importação das imagens e sons.
4. Aperte F5. Movimento: setas ou WASD. Interações: E e botões na tela.
5. No Codex, abra a pasta clonada e peça para ler este README antes de continuar.

## Alternar entre os computadores

Antes de trabalhar, execute `git pull` dentro da pasta. Ao terminar:

```sh
git add .
git commit -m "Descreva o que mudou"
git push
```

Envie as alterações antes de trocar de PC. Se o Git avisar sobre conflitos, resolva-os antes de continuar; não use push forçado.

## Estado do jogo

- Cena inicial: `menu_principal.tscn`.
- Biblioteca: `biblioteca.tscn`, `sala_estantes.tscn` e `recepcao.tscn`.
- Floresta atual: `floresta.tscn`, `floresta_trilha.tscn`, `floresta_sumauma.tscn`.
- Movimento e câmera: `jogador.gd`, `camera_suave.gd`.
- Livro que cai: `livro_misterioso.gd`.
- Livro na mesa e portal: `livro_portal.gd`. Posição e tamanho do portal são ajustáveis no Inspetor.
- Exploração e diálogo do espírito: `floresta.gd`.
- Música persistente: autoload `Trilha`, em `trilha.gd`.
- Arte: `ana-godot/` e `interface/`. Áudio: `audio/`.
- `mapa_prologo.tscn` preserva a versão anterior vista de cima; não é a floresta atual.

## Direção da história

Ana segue um chamado incerto até o Espírito da Sumaúma. A árvore está enfraquecendo, mas o espírito desconhece a causa. Suas sete raízes espirituais alcançam sete regiões, cada uma correspondendo a um capítulo: Prudência, Fortaleza, Justiça, Caridade, Esperança, Temperança e Fé. Biblioteca e primeiro encontro pertencem ao prólogo. Os sete capítulos ainda serão construídos.

## Observações para continuidade

O prólogo mantém metadados da sessão. A partir da entrada na Prudência, o autoload Progresso salva checkpoints e consequências em `user://partida.cfg`; Continuar no menu retoma o capítulo. As opções locais usam `user://`. O cache `.godot/` é recriado automaticamente e não entra no Git. A defesa ativa usa teclado; controle completo mobile ainda precisa ser feito.

O repositório transfere os arquivos do projeto e este contexto. Ele não transfere automaticamente a conversa do Codex nem a partida em andamento.

## Entrada lateral da floresta

A entrada usa a arte original `ana-godot/floresta-lateral-entrada.png`, gerada com a ferramenta de imagens integrada do Codex. A referência visual serviu apenas de inspiração. As outras duas áreas preservam suas artes e também usam caminhada lateral. O portal continua levando à entrada, com retorno para a biblioteca disponível.

Direção da arte: floresta amazônica em pixel art vista de frente, árvores grandes com raízes, névoa azulada, trilha horizontal livre e água com reflexos; sem personagens ou portal incorporados ao fundo.

## Protótipo jogável da Prudência

Após terminar a conversa com o Espírito, interaja novamente para seguir a raiz. Ou abra `prudencia.tscn` no editor e execute a cena com F6. O protótipo cobre sinais ambientais, bifurcação sem dano por erro, aparições, encontro, menus de ação, defesa ativa, duas conclusões e exploração curta posterior. Os cenários existentes são reaproveitados com variações; a silhueta de Nox e os efeitos são provisórios.

- Exploração: A/D ou setas; E para interagir; O para Observar; L para consultar o Livro. Nas escolhas, use mouse ou Tab/setas e Enter.
- Defesa: WASD ou setas em uma faixa delimitada. O chão marcado avisa raízes, folhas anunciam sementes e a marca firme diferencia o ataque real da ilusão.
- Amizade: observar revela ferida e energia; as ações seguintes surgem a partir dessas descobertas. Conversar repetidamente não gera confiança. Atacar reduz confiança, mas é possível reconstruí-la enquanto HP > 0, guardando a arma e respeitando o espaço do guardião durante a defesa.
- Derrota: HP zero encerra a possibilidade pacífica e leva à posse por Nox, sem morte do Curupira. A música é interrompida durante a cena.
- Save: checkpoints de etapa, pistas, ervas, flags do prólogo, `curupira_status`, registro de guardiões e bênçãos. O save não transfere automaticamente pelo GitHub. A partida em meio a um turno retorna ao checkpoint ao reabrir.
- Bênção: Observar revela rastros e uma passagem após a amizade; `Progresso.tem_bencao()` e `consequencia_final()` permitem reutilizar a consequência em encontros futuros. A batalha final e os outros capítulos ainda não foram implementados.

Arquitetura: `prudencia.gd` estende a exploração existente e reaproveita seu diálogo e controle. `sistemas/dialogo.gd` usa a mesma apresentação para sequências de batalha. `batalhas/batalha.gd` orquestra UI e turnos; aceita regras configuráveis. `encontro.gd` contém o puzzle narrativo deste guardião, separado da cena. `defesa.gd` executa padrões telegráficos reutilizáveis. `sistemas/progresso.gd` persiste resultados e bênçãos por guardião.

Validação: regras de amizade e corrupção; recuperação após um a quatro ataques; impossibilidade de resolver só conversando; consumo de itens; save/load; bifurcação; encontro; defesa com aviso; recuo; os dois desfechos completos; retorno do controle e uso da bênção. Os testes usam arquivos de partida separados e não sobrescrevem a partida normal.

Para repetir: `godot --headless --path . --script testes/regras_prudencia.gd` e `godot --headless --path . --script testes/desfechos_prudencia.gd`. O roteiro fornecido está preservado em `docs/prudencia-direcao.txt`.
