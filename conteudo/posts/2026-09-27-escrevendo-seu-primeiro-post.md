%{
  titulo: "Escrevendo seu primeiro post",
  descricao: "Frontmatter, markdown, rascunhos e tags: tudo que cabe num arquivo de post do bloguin.",
  tags: ~w(bloguin tutorial),
  rascunho: true
}
---
Um post do bloguin é um arquivo de texto com duas partes. Vamos abrir um por dentro.

## O nome do arquivo importa

Posts ficam em `conteudo/posts/` e o nome segue o formato `AAAA-MM-DD-slug.md`:

    conteudo/posts/2026-09-27-meu-primeiro-post.md

A data é a data de publicação e o slug vira o endereço do post: esse arquivo aí em cima vira `seu.blog/posts/meu-primeiro-post/`. Trocou o nome, trocou o endereço (então escolhe com carinho).

## O frontmatter

A primeira parte do arquivo é um mapa Elixir com os metadados do post, separado do texto por uma linha com só `---`:

```elixir
%{
  titulo: "Meu primeiro post",
  descricao: "Aparece nas listagens e na descrição da página.",
  tags: ~w(pensamentos elixir),
  rascunho: false
}
---
```

Como é Elixir de verdade, vale sigil e tudo mais que vale num mapa. Os campos:

- `titulo` - obrigatório, aparece no `<h1>` e na aba do navegador
- `descricao` - um resuminho pras listagens e pro RSS
- `tags` - cada tag ganha uma página de listagem em `/tags/nome-da-tag/`
- `rascunho` - com `true`, o post existe no arquivo mas não entra no site gerado

> Se o build reclamar de frontmatter inválido, quase sempre é vírgula faltando ou sobrando no mapa. A mensagem de erro diz qual arquivo foi, prometo.

## O corpo

Depois do `---` é markdown comum (CommonMark com tabelas, tachado e autolinks). Blocos de código com linguagem ganham destaque de sintaxe:

```elixir
defmodule Ola do
  # comentários em português, claro
  def mundo, do: "oi!"
end
```

E é isso. Salva o arquivo e, se o `mix bloguin.servir` estiver rodando, o post já aparece na página inicial.
