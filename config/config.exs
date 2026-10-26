import Config

# Aqui mora tudo que muda de um bloguin pra outro.
# Clonou o repo? Edita esse arquivo e já era.

config :bloguin,
  # aparece no cabeçalho, no <title> e no feed RSS
  titulo_do_site: "jhene.blog",
  autor: "jhene.",
  # usada na meta description e no RSS <span style=\"color: #f586b0\">&lt;
  descricao: "um blog feito com <3 e com bloguin",
  # URL pública do site (sem barra no final), usada no RSS e no sitemap
  url: "https://jhene.blog",
  # diretório do tema: templates .eex + estilo.css + estatico/
  tema: "temas/padrao"
