# Onde editar o jogo

Abra project.godot na raiz. F5 inicia o jogo completo.

| Pasta | Conteúdo |
| --- | --- |
| cenas/interface/ | Menu principal |
| cenas/prologo/ | Biblioteca e início da aventura |
| cenas/floresta/ | Entrada, trilha e Sumaúma |
| cenas/capitulos/prudencia/ | Fase do Curupira; abra prudencia.tscn e use F6 |
| scripts/personagens/ | Movimento e visual da Ana; Francisco |
| scripts/mapas/ | Exploração e entrada do Curupira |
| scripts/batalhas/ | Animações, poderes, falas e regras da batalha |
| scripts/sistemas/ | Saves, música, câmera e transições |
| scripts/prologo/ | Livros, portas e diálogos iniciais |
| scripts/interface/ | Comportamento do menu |
| assets/personagens/ | Sprites por personagem |
| assets/cenarios/ | Fundos e elementos dos mapas |
| assets/objetos/ | Livro e portal |
| assets/interface/ | Botões e menu |
| assets/audio/ | Música e vozes |
| assets/referencias/ | Imagens com nomes de geração preservadas |
| shaders/ | Efeitos visuais |
| testes/ | Verificações automáticas |
| docs/ | Roteiro e instruções |

## Curupira

- Sprites e poderes: assets/personagens/curupira/.
- Recorte e velocidade: scripts/batalhas/curupira_sprite.gd.
- Vida e sequência dos ataques: scripts/batalhas/curupira_dados.gd.
- Trajetória, dano e avisos: scripts/batalhas/defesa.gd.
- Falas da batalha: scripts/batalhas/encontro.gd.
- Entrada e posição: scripts/mapas/prudencia.gd.

As imagens antigas foram preservadas. O pacote aninhado antigo da Ana está em assets/personagens/ana/versoes_anteriores/pacote_original/.

Faça novas movimentações pelo painel Sistema de arquivos do Godot para atualizar referências. A pasta .godot é um cache do editor.
