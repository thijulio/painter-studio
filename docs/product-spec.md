# Especificação funcional — Painter Studio

> Traduz os requisitos do dono em comportamentos testáveis. Cada item referencia o módulo.

## 1. Conta e imagens

- **AUTH-01** — Login com Google (Netlify Identity). Sessão persiste entre sessões.
- **AUTH-02** — Só o dono vê/editam as próprias imagens e inventário.
- **IMG-01** — Enviar imagem (JPG/PNG/WebP) para o S3 via URL pré-assinada.
- **IMG-02** — Galeria pessoal das imagens enviadas.
- **IMG-03** — Excluir imagem (remove do S3 + metadados).

## 2. Análise de cor

- **COL-01** — Dado uma imagem, extrair as N cores dominantes (hex + nome + % de área).
- **COL-02** — Agrupar cores em famílias (neutros, terras, etc.) e exibir swatches clicáveis.
- **COL-03** — Tocar numa cor copia o hex / abre detalhe (harmonias + mistura).

## 3. Tamanho de tela

- **CAN-01** — Dado as dimensões/proporção da imagem, sugerir tamanhos de tela padrão (ex.: 18×24, 24×30, 30×40) mais próximos da proporção.
- **CAN-02** — Permitir escolha manual e personalizada (cm).
- **CAN-03** — Mostrar a proporção vs. a imagem (corte/enquadramento).

## 4. Grelha + impressão A4

- **GRD-01** — Sobrepor grelha configurável (linhas × colunas) na imagem.
- **GRD-02** — Ajustar opacidade/espessura das linhas.
- **GRD-03** — **Gerar PDF em folhas A4**, cada folha com a fração da imagem **na escala real da tela** + marcas de corte/registro.
- **GRD-04** — Indicar total de folhas e layout (linhas × colunas de folhas) antes de baixar.
- **GRD-05** — Formato pronto para papel carbono (linhas de grade visíveis, margem de registro).

## 5. Roda de cores

- **WHL-01** — Roda de cores interativa (HSV/HSL).
- **WHL-02** — Gerar harmonias (complementar, análoga, triádica, tetrádica, monocromática).
- **WHL-03** — A partir de uma cor da roda, mostrar **como chegar nela com as tintas do inventário** (ver §7).

## 6. Inventário de tintas

- **INV-01** — Cadastrar tinta: nome, marca, hex/amostra, família, opacidade, medium (óleo/acrílica/aquarela).
- **INV-02** — Editar/excluir; agrupar por família.
- **INV-03** — Sugerir **famílias** e **paletas** usando as tintas do inventário.
- **INV-04** — Marcar tinta como "tenho/não tenho" (estoque).

## 7. Misturas

- **MIX-01** — Dado uma cor-alvo, calcular receita com as tintas do inventário (delta-E mínimo).
- **MIX-02** — Mostrar proporções aproximadas e swatch resultante.
- **MIX-03** — Avisar que a mistura é **aproximada** (pigmentos são não-lineares).
- **MIX-04** — Salvar receita no histórico do usuário.

## 8. Não-funcionais

- Funcionar offline para leitura (cache local de inventário/imagens).
- Privacidade: imagens privadas por usuário (S3 com controle por identidade).
- Acessível e simples (público-alvo não técnico).
