defmodule Bloguin.PostTest do
  use ExUnit.Case, async: true

  alias Bloguin.Post

  test "build/3 extrai data e slug do nome do arquivo" do
    post = Post.build("conteudo/posts/2026-09-27-ola-mundo.md", %{titulo: "Olá"}, "<p>oi</p>")

    assert post.id == "ola-mundo"
    assert post.data == ~D[2026-09-27]
    assert post.titulo == "Olá"
    assert post.corpo == "<p>oi</p>"
    # valores padrão quando o frontmatter não informa
    assert post.tags == []
    assert post.rascunho == false
  end

  test "caminho/1 é o endereço do post no site" do
    post = Post.build("2026-09-27-ola.md", %{titulo: "Olá"}, "")
    assert Post.caminho(post) == "/posts/ola/"
  end
end
