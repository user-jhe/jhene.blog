defmodule Bloguin.Post do
  @moduledoc """
  Um post do blog, construído a partir de um arquivo markdown.

  O nome do arquivo carrega a data e o slug (endereço) do post:

      conteudo/posts/2026-09-27-meu-primeiro-post.md
                     |________| |________________|
                       data            slug

  O resto das informações vem do frontmatter: `titulo`, `descricao`,
  `tags`, `rascunho` e `serie`.
  """

  @enforce_keys [:id, :data, :titulo, :corpo]
  defstruct [
    :id,
    :data,
    :titulo,
    :corpo,
    :serie,
    descricao: "",
    tags: [],
    rascunho: false
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          data: Date.t(),
          titulo: String.t(),
          corpo: String.t(),
          descricao: String.t(),
          tags: [String.t()],
          rascunho: boolean(),
          serie: String.t() | nil
        }

  # captura a data e o slug do nome do arquivo: AAAA-MM-DD-slug.md
  @regex_nome ~r/(?<data>\d{4}-\d{2}-\d{2})-(?<slug>.+)\.md$/

  @doc """
  Constrói um post a partir do caminho do arquivo, dos atributos do
  frontmatter e do corpo já convertido pra HTML.

  Chamada por `Bloguin.Conteudo.ler/2`, dificilmente você vai chamar
  direto.
  """
  @spec build(Path.t(), map(), String.t()) :: t()
  def build(caminho, attrs, corpo) do
    nome = Path.basename(caminho)
    %{"data" => data, "slug" => slug} = Regex.named_captures(@regex_nome, nome)

    struct!(
      __MODULE__,
      [id: slug, data: Date.from_iso8601!(data), corpo: corpo] ++ Map.to_list(attrs)
    )
  end

  @doc "Endereço do post no site gerado, relativo à raiz."
  @spec caminho(t()) :: String.t()
  def caminho(%__MODULE__{id: id}), do: "/posts/#{id}/"
end
