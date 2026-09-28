defmodule Bloguin.Servidor do
  @moduledoc """
  Servidor de desenvolvimento: serve o `dist/` localmente e reconstrói
  o site quando algum arquivo muda.

  São duas peças, nenhuma delas do bloguin:

  - `:httpd` (vem no Erlang/OTP, pela aplicação `:inets`) serve os
    arquivos estáticos
  - `FileSystem` vigia `conteudo/`, `temas/` e `config/` e avisa
    quando algo muda

  O loop lá embaixo amarra as duas: recebe o aviso de mudança, roda o
  build de novo e volta a esperar. Como o `:httpd` serve direto do
  disco, a página nova já está no ar no próximo refresh.
  """

  require Logger

  @porta 4000
  @vigiados ["conteudo", "temas", "config"]

  # o :httpd precisa saber o tipo de cada extensão pra montar o
  # cabeçalho Content-Type das respostas
  @tipos_mime [
    {~c"html", ~c"text/html"},
    {~c"css", ~c"text/css"},
    {~c"svg", ~c"image/svg+xml"},
    {~c"xml", ~c"application/xml"},
    {~c"png", ~c"image/png"},
    {~c"jpg", ~c"image/jpeg"},
    {~c"ico", ~c"image/x-icon"},
    {~c"woff2", ~c"font/woff2"}
  ]

  @doc """
  Sobe o servidor em http://localhost:4000 e fica vigiando mudanças.

  Essa função não retorna nunca (é um loop infinito de `receive`),
  então quem chama é a mix task `bloguin.servir`.
  """
  @spec servir() :: no_return()
  def servir do
    Bloguin.Construtor.construir()

    {:ok, _pid} = iniciar_httpd()
    {:ok, vigia} = FileSystem.start_link(dirs: @vigiados)
    FileSystem.subscribe(vigia)

    IO.puts("\nbloguin no ar: http://localhost:#{@porta}")

    IO.puts(
      "editando algum arquivo em #{Enum.join(@vigiados, ", ")}? salva que ele reconstrói sozinho"
    )

    loop(vigia)
  end

  # httpd standalone servindo o dist/; a opção directory_index faz
  # "/posts/meu-post/" responder o index.html de dentro da pasta
  defp iniciar_httpd do
    raiz = String.to_charlist(Path.expand("dist"))

    :inets.start(:httpd,
      port: @porta,
      server_name: ~c"bloguin",
      server_root: raiz,
      document_root: raiz,
      directory_index: [~c"index.html"],
      mime_types: @tipos_mime
    )
  end

  defp loop(vigia) do
    receive do
      {:file_event, ^vigia, {caminho, _eventos}} ->
        # editores costumam disparar vários eventos pra um único
        # "salvar" (escreve, renomeia, mexe em permissão...), então a
        # gente espera a poeira baixar e limpa a caixa antes de
        # reconstruir uma vez só
        Process.sleep(100)
        limpar_eventos(vigia)

        IO.puts("\nmudou: #{caminho}")
        Bloguin.Construtor.construir()

        loop(vigia)
    end
  end

  defp limpar_eventos(vigia) do
    receive do
      {:file_event, ^vigia, _} -> limpar_eventos(vigia)
    after
      0 -> :ok
    end
  end
end
