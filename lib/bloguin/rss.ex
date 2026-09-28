defmodule Bloguin.RSS do
  @moduledoc """
  Geração do feed RSS do blog.

  RSS é só um XML com um formato combinado, então aqui a gente monta
  ele na mão com interpolação de string - sem biblioteca, sem mistério.
  O resultado vai parar em `dist/rss.xml` e qualquer leitor de feeds
  (Feedly, Miniflux, NetNewsWire...) entende.
  """

  alias Bloguin.Post

  @doc "Gera o XML completo do feed a partir dos posts (mais novos primeiro)."
  @spec gerar([Post.t()]) :: String.t()
  def gerar(posts) do
    itens = Enum.map_join(posts, "\n", &item/1)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/">
      <channel>
        <title>#{esc(Bloguin.titulo_do_site())}</title>
        <link>#{Bloguin.url()}</link>
        <description>#{esc(Bloguin.descricao())}</description>
        <language>pt-br</language>
        <atom:link href="#{Bloguin.url()}/rss.xml" rel="self" type="application/rss+xml"/>
    #{itens}
      </channel>
    </rss>
    """
  end

  # um <item> por post; o corpo vai num CDATA porque é HTML e não pode
  # ser interpretado como parte do XML
  defp item(%Post{} = post) do
    link = "#{Bloguin.url()}#{Post.caminho(post)}"

    """
        <item>
          <title>#{esc(post.titulo)}</title>
          <link>#{link}</link>
          <guid isPermaLink="true">#{link}</guid>
          <pubDate>#{rfc822(post.data)}</pubDate>
          <description>#{esc(post.descricao)}</description>
          <content:encoded><![CDATA[#{post.corpo}]]></content:encoded>
        </item>
    """
  end

  # RSS exige data no formato RFC 822: "Sun, 27 Sep 2026 00:00:00 +0000"
  defp rfc822(%Date{} = data) do
    data
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
    |> Calendar.strftime("%a, %d %b %Y %H:%M:%S +0000")
  end

  # título e descrição são texto, então escapamos os caracteres que
  # têm significado em XML
  defp esc(texto) do
    texto
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end
end
