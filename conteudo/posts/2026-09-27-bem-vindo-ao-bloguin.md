%{
  titulo: "Bem-vindo ao seu bloguin",
  descricao: "O tour guiado: o que tem nesse repo e como colocar seu blog no ar em cinco minutos.",
  tags: ~w(bloguin),
  rascunho: true
}
---
Senta que lá vem história... brincadeira, dessa vez é rapidinho: esse repositório é o seu blog. Sério, ele inteiro. O bloguin é um gerador de blog estático escrito em Elixir, feito pra você ler o código fonte inteiro numa sentada e entender cada linha.

## Como as coisas se organizam

- `conteudo/` - seus textos em markdown. Posts em `posts/`, páginas soltas em `paginas/`
- `temas/` - a cara do site: templates `.eex` e um `estilo.css`
- `lib/` - o motor. Poucos módulos, todos comentados em português
- `config/config.exs` - título, autor, URL do seu blog

O fluxo é esse: o bloguin lê seus `.md`, converte pra HTML, passa pelos templates do tema e escreve o site pronto em `dist/`. Não tem banco de dados, não tem servidor, não tem Node. O resultado é um punhado de arquivos estáticos que roda em qualquer lugar.

## Colocando no ar localmente

Precisa só de Elixir instalado (1.19 ou mais nova). No terminal:

```bash
mix deps.get
mix bloguin.servir
```

Abre http://localhost:4000 e tá lá o seu bloguin. Deixa o comando rodando: cada vez que você salvar um arquivo, o site é reconstruído sozinho.

## Próximos passos

1. Edita `config/config.exs` com o seu nome e o título do seu blog
2. Apaga esses posts de exemplo e [escreve o seu primeiro](/posts/escrevendo-seu-primeiro-post/)
3. [Personaliza o tema](/posts/personalizando-o-tema/) até ficar com a sua cara
4. Faz deploy (o README mostra três jeitos, todos gratuitos)

Ah, e esse post aqui é um arquivo como outro qualquer: abre `conteudo/posts/2026-09-27-bem-vindo-ao-bloguin.md` no seu editor e vê como ele é por dentro!
