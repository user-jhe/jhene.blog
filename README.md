# bloguin

Um gerador de blog estático em Elixir, pequeno o suficiente pra você ler o código fonte inteiro. Foi feito pra quem está aprendendo Elixir e quer um blog de verdade no final do caminho: sem banco de dados, sem Node, sem framework web, sem mágica.

O fluxo inteiro cabe numa frase:

```
conteúdo (markdown) -> templates (.eex) -> dist/ (site pronto)
```

Você escreve textos em markdown, o bloguin converte pra HTML usando os templates do tema e cospe um diretório `dist/` de arquivos estáticos que roda em qualquer lugar que sirva arquivo. Qualquer lugar mesmo: um VPS de dois trocados, GitHub Pages, Netlify, um Raspberry Pi embaixo da cama.

## Requisitos

- Elixir 1.19+ e Erlang/OTP 27+ (com `mix`, claro)

E só. O markdown é convertido por um NIF pré-compilado (não precisa de Rust instalado) e o destaque de sintaxe é Elixir puro.

## Começando

Esse repositório é um template: clica em **"Use this template"** ali em cima no GitHub (ou clona na mão mesmo) e o repo passa a ser seu. Depois:

```bash
mix deps.get
mix bloguin.servir
```

Abre http://localhost:4000 e o seu bloguin tá no ar, com três posts de exemplo que dobram como tutorial. Deixa o comando rodando enquanto escreve: cada arquivo salvo em `conteudo/`, `temas/` ou `config/` reconstrói o site sozinho.

Antes de mais nada, edita `config/config.exs`: título do site, seu nome, a URL onde ele vai morar. É o único arquivo de configuração que existe.

## Escrevendo

Posts são arquivos em `conteudo/posts/` com nome `AAAA-MM-DD-slug.md`:

```elixir
%{
  titulo: "Meu primeiro post",
  descricao: "Um resuminho pras listagens e pro RSS.",
  tags: ~w(pensamentos elixir),
  rascunho: false
}
---
Aqui vai o markdown, com **tudo** que você já conhece.
```

O frontmatter é um mapa Elixir de verdade (vale sigil, vale `~D[data]`), o corpo é CommonMark com tabelas e destaque de sintaxe pra Elixir e Erlang. `rascunho: true` guarda o post no arquivo sem publicar.

Páginas soltas (sobre, contato, uses) moram em `conteudo/paginas/` e viram endereços na raiz: `sobre.md` vira `/sobre/`.

> Os posts de exemplo que vem no repo contam essa história com mais calma: [escrevendo seu primeiro post](conteudo/posts/2026-09-27-escrevendo-seu-primeiro-post.md) e [personalizando o tema](conteudo/posts/2026-09-27-personalizando-o-tema.md). Apaga eles quando estiver pronta!

## Personalizando

A cara do site mora em `temas/padrao/`: um `estilo.css` com variáveis de cor no topo e templates `.eex` pra cada tipo de página. EEx é o motor de templates da biblioteca padrão do Elixir - HTML com `<%= coisas %>` no meio, nenhuma dependência.

Quer um tema seu? Copia o diretório, aponta a config e edita sem medo:

```bash
cp -r temas/padrao temas/meu-tema
# config/config.exs -> tema: "temas/meu-tema"
```

O modo escuro já vem resolvido com `prefers-color-scheme`, sem uma linha de JavaScript.

## Deploy

`mix bloguin.construir` gera o `dist/`. Daí em diante é só colocar esse diretório em algum lugar que sirva arquivos. Três jeitos, do mais preguiçoso ao mais raiz:

**GitHub Pages (grátis, sem servidor).** O repo já traz um workflow em `.github/workflows/deploy.yml`: vai em Settings -> Pages, muda a fonte pra "GitHub Actions" e cada push na `main` publica o site automaticamente.

**Netlify (grátis, arrasta e solta).** Roda `mix bloguin.construir` local e arrasta a pasta `dist/` pra dentro do painel da Netlify. Dá pra automatizar depois com `netlify deploy --dir=dist --prod`, mas começa no arrasta e solta que é mais feliz.

**VPS (raiz e com certificado).** Qualquer nginx servindo o diretório resolve:

```nginx
server {
    listen 80;
    server_name seu.blog;
    root /var/www/bloguin;
    location / { try_files $uri $uri/ =404; }
}
```

E um `rsync -avz dist/ usuario@servidor:/var/www/bloguin/` publica. Certbot cuida do HTTPS de graça.

## Como o código se organiza

O motor inteiro são sete módulos em `lib/`, todos comentados em português (o público aqui é você que está aprendendo, então os comentários explicam as decisões):

| módulo | papel |
|---|---|
| `Bloguin` | acesso à configuração do site |
| `Bloguin.Conteudo` | lê os `.md`: frontmatter, markdown, destaque de sintaxe |
| `Bloguin.Post` / `Bloguin.Pagina` | as structs de conteúdo |
| `Bloguin.Tema` | renderiza os `.eex` |
| `Bloguin.RSS` | gera o feed na mão (RSS é só XML) |
| `Bloguin.Construtor` | o maestro: junta tudo e escreve o `dist/` |
| `Bloguin.Servidor` | servidor de dev com rebuild automático |

Começa pelo `Bloguin.Construtor`: cada etapa do build é uma função privada na ordem em que acontece, dá pra ler como uma receita. Depois segue o rastro pras outras partes!

## Estendendo

Algumas ideias de onde pendurar coisas novas, em ordem de ousadia:

1. Um template `.eex` novo no tema + uma chamada a `Bloguin.Tema.renderizar/2` no construtor = um tipo de página novo
2. Campos novos no frontmatter entram de graça (o mapa vira a struct direto), só adicionar a chave no `defstruct`
3. Um lexer novo do Makeup (`makeup_html`, `makeup_json`...) = destaque de sintaxe pra mais linguagens, é só adicionar a dependência

## Licença

MIT. Faz o que quiser, inclusive apagar esse README e fingir que sempre foi seu (mas conta pra alguém que o bloguin existe, vai 💜)
