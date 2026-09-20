# Deploy no Netlify

O `netlify.toml` já está configurado (build web + functions + publish dir). Para
publicar, conecte o repo GitHub ao Netlify.

## Pré-requisito: token do GitHub Packages

O build instala `@thijulio/biome-tokens` do GitHub Packages (privado), então o
Netlify precisa de um token. Use um GitHub PAT com scope `read:packages`.

Rápido (usa o token do `gh`):
```bash
gh auth token   # copia a saída
```

## Passos (interface web)

1. Vá em https://app.netlify.com → **Add new site → Import an existing project**.
2. Escolha **GitHub** e selecione `thijulio/painter-studio`.
3. O Netlify lê o `netlify.toml` automaticamente (build command, publish dir, functions).
4. **Antes do primeiro deploy**, adicione a env var:
   - Site settings → **Environment variables** → adicione `NODE_AUTH_TOKEN` = (token do passo acima).
5. Clique **Deploy**.

## Depois

- Toda vez que você der `git push` na `main`, o Netlify faz deploy automático.
- URL do site: `https://<nome>.netlify.app`.
- Functions em `/.netlify/functions/hello` (smoke-test).
