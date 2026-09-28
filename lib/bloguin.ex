defmodule Bloguin do
  @moduledoc """
  Ponto de entrada do bloguin e acesso à configuração do site.

  O bloguin é um gerador de blog estático: ele lê arquivos markdown em
  `conteudo/`, renderiza com os templates do tema em `temas/` e escreve
  o site pronto em `dist/`. Sem banco de dados, sem servidor, sem mágica.

  O fluxo inteiro cabe numa frase:

      conteúdo (markdown) -> Bloguin.Conteudo -> Bloguin.Tema -> dist/

  As configurações do site (título, autor, URL...) ficam em
  `config/config.exs` e são lidas pelas funções deste módulo.
  """

  @doc "Título do site, usado no cabeçalho, no `<title>` e no RSS."
  def titulo_do_site, do: config(:titulo_do_site)

  @doc "Nome da pessoa autora, usado no rodapé e no RSS."
  def autor, do: config(:autor)

  @doc "Descrição curta do site, usada na meta description e no RSS."
  def descricao, do: config(:descricao)

  @doc "URL pública do site, sem barra no final. Base dos links do RSS e do sitemap."
  def url, do: config(:url)

  @doc "Diretório do tema ativo (templates .eex, estilo.css e estatico/)."
  def tema, do: config(:tema)

  @doc "Mapa com tudo que os templates recebem como `site`."
  def site do
    %{
      titulo: titulo_do_site(),
      autor: autor(),
      descricao: descricao(),
      url: url()
    }
  end

  defp config(chave) do
    Application.get_env(:bloguin, chave) ||
      raise "configuração #{inspect(chave)} não encontrada em config/config.exs"
  end
end
