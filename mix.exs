defmodule Bloguin.MixProject do
  use Mix.Project

  def project do
    [
      app: :bloguin,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Sem aplicação OTP: o bloguin é um conjunto de mix tasks que geram
  # arquivos estáticos, não tem nada rodando em produção.
  # (:inets entra pro servidor de desenvolvimento do bloguin.servir)
  def application do
    [
      extra_applications: [:logger, :inets]
    ]
  end

  defp deps do
    [
      # markdown -> html (comrak, NIF pré-compilado: não precisa de Rust instalado)
      {:mdex_native, "~> 0.2"},
      # destaque de sintaxe nos blocos de código
      {:makeup, "~> 1.0"},
      {:makeup_elixir, "~> 1.0"},
      {:makeup_erlang, "~> 1.0"},
      # vigia de arquivos pro `mix bloguin.servir`
      {:file_system, "~> 1.0"}
    ]
  end
end
