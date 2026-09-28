defmodule Bloguin.Construtor do
  @moduledoc """
  O construtor do site: junta conteúdo e tema e escreve o `dist/`.

  O fluxo, na ordem:

  1. lê todos os posts de `conteudo/posts/` (rascunhos ficam de fora)
  2. lê todas as páginas de `conteudo/paginas/`
  3. renderiza cada coisa com o tema e escreve em `dist/`
  4. gera `rss.xml` e `sitemap.xml`
  5. copia o `estilo.css` e o `estatico/` do tema

  Cada etapa é uma função privada aqui embaixo, na mesma ordem - pode
  ler o módulo de cima a baixo como se fosse uma receita.
  """

  alias Bloguin.{Conteudo, Pagina, Post, Tema}

  @saida "dist"

  @doc "Constrói o site inteiro no diretório `dist/`."
  @spec construir() :: :ok
  def construir do
    posts = carregar_posts!()
    paginas = carregar_paginas!()

    File.rm_rf!(@saida)
    File.mkdir_p!(@saida)

    escrever("", "index.html", Tema.renderizar("inicio", site: Bloguin.site(), posts: posts))

    Enum.each(posts, &escrever_post/1)
    Enum.each(paginas, &escrever_pagina/1)
    escrever_tags(posts)

    escrever("", "rss.xml", Bloguin.RSS.gerar(posts))
    escrever("", "sitemap.xml", sitemap(posts, paginas))

    copiar_tema()

    IO.puts("\nprontinho: #{length(posts)} posts e #{length(paginas)} páginas em #{@saida}/")
    :ok
  end

  # lê os posts, tira os rascunhos e ordena do mais novo pro mais velho
  defp carregar_posts! do
    "conteudo/posts/*.md"
    |> carregar!(Post)
    |> Enum.reject(& &1.rascunho)
    |> Enum.sort_by(& &1.data, {:desc, Date})
  end

  defp carregar_paginas! do
    carregar!("conteudo/paginas/*.md", Pagina)
  end

  # lê cada arquivo do padrão; qualquer erro vira uma mensagem que diz
  # exatamente qual arquivo quebrou (ninguém merece caçar arquivo ruim)
  defp carregar!(padrao, modulo) do
    for caminho <- Path.wildcard(padrao) do
      case Conteudo.ler(caminho, modulo) do
        {:ok, struct} -> struct
        {:error, motivo} -> raise "erro ao ler #{caminho}: #{motivo}"
      end
    end
  end

  defp escrever_post(%Post{} = post) do
    html =
      Tema.renderizar("post",
        site: Bloguin.site(),
        post: post,
        titulo_pagina: post.titulo,
        descricao: post.descricao
      )

    escrever(Post.caminho(post), "index.html", html)
  end

  defp escrever_pagina(%Pagina{} = pagina) do
    html =
      Tema.renderizar("pagina",
        site: Bloguin.site(),
        pagina: pagina,
        titulo_pagina: pagina.titulo,
        descricao: pagina.descricao
      )

    escrever(Pagina.caminho(pagina), "index.html", html)
  end

  # agrupa os posts por tag e gera uma listagem pra cada uma
  defp escrever_tags(posts) do
    posts
    |> Enum.flat_map(fn post -> Enum.map(post.tags, &{&1, post}) end)
    |> Enum.group_by(fn {tag, _post} -> tag end, fn {_tag, post} -> post end)
    |> Enum.each(fn {tag, posts_da_tag} ->
      html =
        Tema.renderizar("tag",
          site: Bloguin.site(),
          tag: tag,
          posts: posts_da_tag,
          titulo_pagina: "##{tag}"
        )

      escrever("/tags/#{tag}/", "index.html", html)
    end)
  end

  # sitemap.xml: a lista de endereços do site pros buscadores
  # (também é só um XML montado na mão, igual ao RSS)
  defp sitemap(posts, paginas) do
    urls =
      ["/"] ++
        Enum.map(posts, &Post.caminho/1) ++
        Enum.map(paginas, &Pagina.caminho/1)

    entradas =
      Enum.map_join(urls, "\n", fn caminho ->
        "  <url><loc>#{Bloguin.url()}#{caminho}</loc></url>"
      end)

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    #{entradas}
    </urlset>
    """
  end

  # o estilo.css e o conteúdo de estatico/ vão pro dist como estão
  defp copiar_tema do
    tema = Bloguin.tema()

    File.cp!(Path.join(tema, "estilo.css"), Path.join(@saida, "estilo.css"))

    estatico = Path.join(tema, "estatico")

    if File.dir?(estatico) do
      File.cp_r!(estatico, @saida)
    end

    IO.puts("  estilo.css + estatico/")
  end

  # escreve um arquivo no dist e conta pra gente (o caminho vem no
  # formato "/posts/meu-post/", então Path.join cuida das barras)
  defp escrever(diretorio, arquivo, conteudo) do
    destino = Path.join([@saida, diretorio, arquivo])
    File.mkdir_p!(Path.dirname(destino))
    File.write!(destino, conteudo)

    IO.puts("  #{Path.join(diretorio, arquivo)}")
  end
end
