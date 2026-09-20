// Metro config para monorepo pnpm (Expo). Ver https://docs.expo.dev/guides/monorepos/
const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, '../..');

const config = getDefaultConfig(projectRoot);

// Observa todos os arquivos do monorepo (packages compartilhados).
config.watchFolders = [workspaceRoot];

// Resolve do app primeiro, depois da raiz do workspace (hoisting do pnpm).
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, 'node_modules'),
  path.resolve(workspaceRoot, 'node_modules'),
];

module.exports = config;
