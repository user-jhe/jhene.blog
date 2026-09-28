defmodule Bloguin.ConteudoTest do
  use ExUnit.Case, async: true

  alias Bloguin.Conteudo

  @texto """
  %{
    titulo: "Post de teste",
    tags: ~w(elixir teste)
  }
  ---
  # Oi

  Um parágrafo de *markdown*.

  ```elixir
  def oi, do: :mundo
  ```
  """

  test "dividir/1 separa o frontmatter do corpo" do
    assert {:ok, attrs, corpo} = Conteudo.dividir(@texto)
    assert attrs == %{titulo: "Post de teste", tags: ~w(elixir teste)}
    assert corpo =~ "# Oi"
  end

  test "dividir/1 sem a linha separadora dá erro" do
    assert {:error, :sem_frontmatter} = Conteudo.dividir("só markdown, nada de mapa")
  end

  test "dividir/1 com frontmatter que não é mapa dá erro" do
    assert {:error, :frontmatter_invalido} = Conteudo.dividir("1 + 1\n---\ncorpo")
  end

  test "para_html/1 converte markdown e destaca código elixir" do
    html = Conteudo.para_html("# Título\n\n```elixir\ndef oi, do: :mundo\n```\n")

    assert html =~ "<h1>"
    assert html =~ ~s(class="makeup elixir")
    # o Makeup embrulha tokens em spans; se tem span, o destaque rolou
    assert html =~ "<span"
  end

  test "para_html/1 não destaca linguagem desconhecida" do
    html = Conteudo.para_html("```klingon\nQapla'\n```\n")
    refute html =~ "makeup"
  end

  test "ler/2 constrói um post a partir do arquivo" do
    caminho = Path.join(System.tmp_dir!(), "2026-09-27-post-de-teste.md")
    File.write!(caminho, @texto)

    assert {:ok, %Bloguin.Post{} = post} = Conteudo.ler(caminho, Bloguin.Post)
    assert post.id == "post-de-teste"
    assert post.titulo == "Post de teste"
    assert post.corpo =~ "makeup elixir"

    File.rm!(caminho)
  end
end
