defmodule Mix.Tasks.Bloguin.Construir do
  @moduledoc """
  Constrói o site no diretório `dist/`:

      mix bloguin.construir

  Depois disso é só publicar o `dist/` em qualquer lugar que sirva
  arquivos estáticos (o README tem uma seção inteira sobre deploy).
  """

  use Mix.Task

  @shortdoc "Constrói o site em dist/"
  @impl Mix.Task
  def run(_args) do
    # mix tasks não sobem a aplicação sozinhas; sem isso o Makeup
    # não registra os lexers e o destaque de sintaxe quebra
    Mix.Task.run("app.start")

    Bloguin.Construtor.construir()
  end
end
