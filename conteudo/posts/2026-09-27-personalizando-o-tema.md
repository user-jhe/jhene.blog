%{
  titulo: "Personalizando o tema",
  descricao: "Variáveis de CSS, templates EEx e como criar um tema seu sem medo de quebrar nada.",
  tags: ~w(bloguin tutorial css)
}
---
A cara do bloguin mora inteirinha em `temas/padrao/`. Não tem framework de CSS, não tem build de assets, não tem JavaScript. É um arquivo `.css` e uns templates `.eex`, e você pode mudar tudo.

## O caminho mais curto: as variáveis

Abre `temas/padrao/estilo.css` e olha o topo:

```css
:root {
  --fundo: #faf6f0;
  --texto: #2e2a25;
  --destaque: #9a5b24;
  /* ... */
}
```

Trocou o valor de `--destaque`, trocou a cor de todos os links do site. O modo escuro é um bloco `@media (prefers-color-scheme: dark)` logo abaixo com as mesmas variáveis, então o site segue a preferência do sistema de quem lê, de graça.

## Os templates

Cada tipo de página tem um `.eex`:

- `layout.eex` - a casca com `<head>`, cabeçalho e rodapé
- `inicio.eex` - a listagem de posts
- `post.eex` - um post individual
- `pagina.eex` - páginas soltas como a de "sobre"
- `tag.eex` - a listagem de uma tag

EEx é o motor de templates da biblioteca padrão do Elixir: HTML com `<%= coisas %>` no meio. Dentro dos templates você tem `@site` (título, autor, URL) e as variáveis de cada página, documentadas num comentário no topo de cada arquivo.

Uma pegadinha pra quem vem do Phoenix: o EEx não escapa HTML sozinho. Por isso os templates usam `Bloguin.Tema.esc/1` em todo texto que vem do frontmatter - o corpo do post fica de fora porque ele já é HTML.

## Um tema só seu

```bash
cp -r temas/padrao temas/meu-tema
```

Edita `config/config.exs` e aponta `tema: "temas/meu-tema"`. Pronto, o tema padrão fica intacto pra consulta e você experimenta à vontade no seu. Quer adicionar um tipo de página novo (um arquivo de projetos, uma página de livros lidos)? Cria um `.eex` novo no tema e chama `Bloguin.Tema.renderizar/2` no `Bloguin.Construtor` - o módulo é curtinho e cada etapa do build é uma função, acha o lugar certo rapidinho.
