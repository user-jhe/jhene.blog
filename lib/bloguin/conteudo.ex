defmodule Bloguin.Conteudo do
  @moduledoc """
  Leitura dos arquivos markdown: frontmatter, conversão pra HTML e
  destaque de sintaxe. É aqui que um `.md` vira dados.

  Cada arquivo de conteúdo tem duas partes, separadas por uma linha
  contendo só `---`:

      %{
        titulo: "Meu post",
        tags: ~w(elixir)
      }
      ---
      Aqui começa o markdown de verdade.

  O frontmatter é um mapa Elixir de verdade (avaliado com
  `Code.eval_string/1`), então vale tudo que vale num mapa: sigils,
  `~D[data]`, listas... Repare que isso significa que o conteúdo é
  confiável por definição - nunca aponte o bloguin pra markdown
  escrito por estranhos.
  """

  # bloco de código renderizado pelo comrak: <pre><code class="language-elixir">...</code></pre>
  # o prefixo "language-" é opcional no regex pra aceitar HTML vindo de outras fontes
  @regex_codigo ~r/<pre><code(?:\s+class="(?:language-)?([^"\s]*)")?>([^<]*)<\/code><\/pre>/

  # opções do comrak (o motor de markdown do mdex): tabelas, autolinks,
  # tachado e HTML cru liberado (o conteúdo é nosso mesmo, pode confiar)
  @opcoes_mdex [
    extension: [table: true, autolink: true, strikethrough: true],
    render: [hardbreaks: false, unsafe: true]
  ]

  @doc """
  Lê um arquivo de conteúdo e devolve `{:ok, struct}` construído pelo módulo
  informado (`Bloguin.Post` ou `Bloguin.Pagina`).

  ## Exemplo

      {:ok, post} = Bloguin.Conteudo.ler("conteudo/posts/2026-09-27-oi.md", Bloguin.Post)

  """
  @spec ler(Path.t(), module()) :: {:ok, struct()} | {:error, atom()}
  def ler(caminho, modulo) do
    with {:ok, texto} <- File.read(caminho),
         {:ok, attrs, markdown} <- dividir(texto) do
      {:ok, modulo.build(caminho, attrs, para_html(markdown))}
    end
  end

  @doc """
  Separa o frontmatter do corpo do markdown.

  Devolve `{:ok, mapa_de_atributos, corpo_markdown}` ou `{:error, motivo}`.
  """
  @spec dividir(String.t()) ::
          {:ok, map(), String.t()} | {:error, :sem_frontmatter | :frontmatter_invalido}
  def dividir(texto) when is_binary(texto) do
    linhas = String.split(texto, "\n")

    case Enum.find_index(linhas, &(&1 == "---")) do
      nil ->
        {:error, :sem_frontmatter}

      indice ->
        cabecalho = linhas |> Enum.take(indice) |> Enum.join("\n")
        corpo = linhas |> Enum.drop(indice + 1) |> Enum.join("\n")

        case avaliar(cabecalho) do
          {:ok, attrs} -> {:ok, attrs, corpo}
          erro -> erro
        end
    end
  end

  @doc "Converte markdown pra HTML já com o destaque de sintaxe aplicado."
  @spec para_html(String.t()) :: String.t()
  def para_html(markdown) do
    markdown
    |> MDExNative.Comrak.markdown_to_html(@opcoes_mdex)
    |> destacar_codigo()
  end

  # o frontmatter é código Elixir, então a gente avalia e confere se
  # o resultado é um mapa (qualquer outra coisa é frontmatter inválido)
  defp avaliar(cabecalho) do
    case Code.eval_string(cabecalho) do
      {%{} = attrs, _binding} -> {:ok, attrs}
      _outro -> {:error, :frontmatter_invalido}
    end
  rescue
    _ -> {:error, :frontmatter_invalido}
  end

  # passa o Makeup em cada bloco de código que tem linguagem conhecida;
  # blocos sem linguagem (ou com linguagem que a gente não tem lexer)
  # ficam como estão
  defp destacar_codigo(html) do
    Regex.replace(@regex_codigo, html, fn original, linguagem, codigo ->
      if linguagem != "" && Makeup.Registry.get_lexer_by_name(linguagem) do
        destacado =
          codigo
          |> desescapar_html()
          |> Makeup.highlight_inner_html(lexer: linguagem)

        ~s(<pre><code class="makeup #{linguagem}">#{destacado}</code></pre>)
      else
        original
      end
    end)
  end

  # o comrak escapa entidades HTML dentro do código (& vira &amp; e por
  # aí vai), mas o Makeup espera o código cru - então a gente desfaz o
  # escape antes de destacar
  defp desescapar_html(texto) do
    texto
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
    |> String.replace("&amp;", "&")
  end
end
