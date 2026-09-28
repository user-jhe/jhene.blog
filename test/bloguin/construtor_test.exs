defmodule Bloguin.ConstrutorTest do
  # síncrono de propósito: o build escreve no disco, nada de dois
  # testes mexendo no dist/ ao mesmo tempo
  use ExUnit.Case, async: false

  alias Bloguin.Construtor

  setup do
    Construtor.construir()
    on_exit(fn -> File.rm_rf!("dist") end)
    :ok
  end

  test "gera a página inicial com a listagem de posts" do
    html = File.read!("dist/index.html")
    assert html =~ "Bem-vindo ao seu bloguin"
  end

  test "gera uma página pra cada post, com destaque de sintaxe" do
    html = File.read!("dist/posts/escrevendo-seu-primeiro-post/index.html")
    assert html =~ "makeup elixir"
  end

  test "gera página solta na raiz" do
    assert File.read!("dist/sobre/index.html") =~ "Sobre"
  end

  test "gera listagem por tag" do
    html = File.read!("dist/tags/tutorial/index.html")
    assert html =~ "Escrevendo seu primeiro post"
  end

  test "gera rss e sitemap" do
    assert File.read!("dist/rss.xml") =~ "<rss version=\"2.0\""
    assert File.read!("dist/sitemap.xml") =~ "<urlset"
  end

  test "copia os arquivos do tema" do
    assert File.exists?("dist/estilo.css")
    assert File.exists?("dist/favicon.svg")
  end

  test "rascunhos não entram no site" do
    rascunho = "conteudo/posts/2026-01-01-segredo.md"
    File.write!(rascunho, "%{titulo: \"Segredo\", rascunho: true}\n---\nshhh\n")
    on_exit(fn -> File.rm!(rascunho) end)

    Construtor.construir()

    refute File.exists?("dist/posts/segredo/index.html")
    refute File.read!("dist/index.html") =~ "Segredo"
  end
end
