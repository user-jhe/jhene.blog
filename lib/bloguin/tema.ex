defmodule Bloguin.Tema do
  @moduledoc """
  Renderização dos templates do tema com EEx (que faz parte da
  biblioteca padrão do Elixir - nenhuma dependência aqui).

  Um tema é só um diretório com arquivos `.eex`:

      temas/padrao/
        layout.eex   # casca HTML: <head>, cabeçalho, rodapé
        inicio.eex   # listagem de posts
        post.eex     # um post
        pagina.eex   # uma página solta
        tag.eex      # listagem de posts de uma tag

  Os templates recebem variáveis via `assigns`, acessadas com `@nome`
  dentro do `.eex` - igualzinho ao Phoenix, mas sem Phoenix nenhum
  por perto. Todo template recebe `@site` (título, autor, URL) além
  das variáveis específicas de cada um.

  Pra criar um tema novo: copie `temas/padrao`, mude o que quiser e
  aponte a config `:tema` em `config/config.exs` pro novo diretório.
  """

  @doc """
  Renderiza um template do tema dentro do layout.

  Recebe o nome do template (sem extensão) e os assigns. O template é
  renderizado primeiro e o resultado entra no `layout.eex` como
  `@conteudo`.
  """
  @spec renderizar(String.t(), keyword()) :: String.t()
  def renderizar(template, assigns) do
    conteudo = avaliar(template, assigns)

    layout_assigns =
      assigns
      |> Keyword.put(:conteudo, conteudo)
      |> Keyword.put_new(:titulo_pagina, nil)
      |> Keyword.put_new(:descricao, Bloguin.descricao())

    avaliar("layout", layout_assigns)
  end

  @doc """
  Escapa texto pra entrar com segurança no HTML.

  O EEx não escapa nada sozinho (diferente do HEEx do Phoenix), então
  todo texto que vem do frontmatter passa por aqui nos templates:
  `<%= Bloguin.Tema.esc(@post.titulo) %>`. O corpo do post não passa
  porque ele já é HTML de propósito.
  """
  @spec esc(String.t() | nil) :: String.t()
  def esc(nil), do: ""

  def esc(texto) do
    texto
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  # avalia o .eex do tema com os assigns; o engine padrão do EEx
  # entende @variavel lendo da variável `assigns`, por isso a gente
  # passa a lista inteira com esse nome
  defp avaliar(template, assigns) do
    caminho = Path.join([Bloguin.tema(), "#{template}.eex"])

    unless File.exists?(caminho) do
      raise "template #{caminho} não existe no tema #{Bloguin.tema()}"
    end

    EEx.eval_file(caminho, assigns: assigns)
  end
end
