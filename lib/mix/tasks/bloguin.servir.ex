defmodule Mix.Tasks.Bloguin.Servir do
  @moduledoc """
  Constrói o site e sobe um servidor local com reconstrução automática:

      mix bloguin.servir

  Deixa rodando enquanto escreve: cada arquivo salvo em `conteudo/`,
  `temas/` ou `config/` dispara um build novo. Ctrl+C duas vezes pra
  parar.
  """

  use Mix.Task

  @shortdoc "Serve o site em localhost:4000 com rebuild automático"
  @impl Mix.Task
  def run(_args) do
    # sobe a aplicação (e as dependências): o Makeup precisa registrar
    # os lexers e o :inets precisa estar no ar pro servidor
    Mix.Task.run("app.start")

    Bloguin.Servidor.servir()
  end
end
