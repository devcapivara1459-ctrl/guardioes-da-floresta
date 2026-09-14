# Guardiões da Floresta

Jogo 2D em Godot 4.7.2. Prólogo: biblioteca, livro misterioso, portal e encontro com o Espírito da Sumaúma. A floresta usa cenários vistos de frente, com movimento nas quatro direções. Diálogos somente em texto; música contínua e baixa durante o jogo.

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

O progresso narrativo usa metadados da sessão do Godot: ainda não há salvamento permanente da partida. As opções locais usam `user://`. O cache `.godot/` é recriado automaticamente e não entra no Git. Botões de interação aceitam toque; o controle completo de movimento mobile ainda precisa ser feito.

O repositório transfere os arquivos do projeto e este contexto. Ele não transfere automaticamente a conversa do Codex nem a partida em andamento.
