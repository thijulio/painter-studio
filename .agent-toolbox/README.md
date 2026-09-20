# .agent-toolbox — AI Toolbox instalado

Diretório de instalação do [thijulio-ai-toolbox](https://github.com/thijulio/thijulio-ai-toolbox).

## Instalar

```bash
# instala o plugin numa versão exata (publicado como @thijulio/governance-core)
governance-core install --project .
# depois registre o plugin local no host (Claude Code / Codex) — ver
# docs/installation.md do toolbox.
```

O install escreve apenas:
- `.agent-toolbox/installed/governance-core/` (gerado; ignorado no git)
- `.agent-toolbox/install-lock.json` (commitado — trava a versão)

A política do projeto permanece do dono (o plugin é **read-only**).
Para remover: desregistre no host e rode `governance-core uninstall --project .`.
