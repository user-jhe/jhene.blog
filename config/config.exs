import Config

# Aqui mora tudo que muda de um bloguin pra outro.
# Clonou o repo? Edita esse arquivo e já era.

config :bloguin,
  # aparece no cabeçalho, no <title> e no feed RSS
  titulo_do_site: "meu bloguin",
  autor: "seu nome aqui",
  # usada na meta description e no RSS
  descricao: "um blog feito com bloguin",
  # URL pública do site (sem barra no final), usada no RSS e no sitemap
  url: "https://exemplo.dev",
  # diretório do tema: templates .eex + estilo.css + estatico/
  tema: "temas/padrao"
