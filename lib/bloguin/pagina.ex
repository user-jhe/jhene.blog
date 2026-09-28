defmodule Bloguin.Pagina do
  @moduledoc """
  Uma página solta do site (sobre, contato, uses...) - igual a um post,
  mas sem data, tags ou listagens: vive direto na raiz do endereço.

      conteudo/paginas/sobre.md  ->  https://seu.blog/sobre/

  O frontmatter pede só `titulo` e `descricao`.
  """

  @enforce_keys [:id, :titulo, :corpo]
  defstruct [:id, :titulo, :corpo, descricao: ""]

  @type t :: %__MODULE__{
          id: String.t(),
          titulo: String.t(),
          corpo: String.t(),
          descricao: String.t()
        }

  @doc """
  Constrói uma página a partir do caminho do arquivo, dos atributos do
  frontmatter e do corpo já convertido pra HTML. O slug vem do nome do
  arquivo sem a extensão.
  """
  @spec build(Path.t(), map(), String.t()) :: t()
  def build(caminho, attrs, corpo) do
    slug = caminho |> Path.basename(".md")

    struct!(__MODULE__, [id: slug, corpo: corpo] ++ Map.to_list(attrs))
  end

  @doc "Endereço da página no site gerado, relativo à raiz."
  @spec caminho(t()) :: String.t()
  def caminho(%__MODULE__{id: id}), do: "/#{id}/"
end
