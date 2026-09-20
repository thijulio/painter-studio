// Smoke-test: prova que o diretório `functions/` está ligado ao Netlify.
exports.handler = async () => ({
  statusCode: 200,
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ ok: true, app: "painter-studio", phase: 0 }),
});
