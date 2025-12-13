#!/usr/bin/env node
/**
 * AgentVibes Postinstall Script
 *
 * Runs after npm install to:
 * 1. Install MCP Python dependencies (original behavior)
 * 2. Setup user-level AgentVibes configuration (new)
 */

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { existsSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');

/**
 * Run a command and return a promise
 */
function runCommand(command, args, options = {}) {
  return new Promise((resolve, reject) => {
    console.log(`Running: ${command} ${args.join(' ')}`);

    const child = spawn(command, args, {
      stdio: 'inherit',
      shell: true,
      ...options
    });

    child.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Command failed with code ${code}`));
      }
    });

    child.on('error', (err) => {
      reject(err);
    });
  });
}

async function main() {
  console.log('\n=== AgentVibes Postinstall ===\n');

  // Step 1: Run original MCP dependencies installer
  const installDepsPath = join(rootDir, 'mcp-server', 'install-deps.js');
  if (existsSync(installDepsPath)) {
    console.log('[1/2] Installing MCP dependencies...');
    try {
      await runCommand('node', [installDepsPath]);
    } catch (err) {
      console.warn('Warning: MCP deps install failed (may not be needed):', err.message);
    }
  }

  // Step 2: Run user-level setup
  const setupScript = join(rootDir, 'scripts', 'install-user-level.sh');
  if (existsSync(setupScript)) {
    console.log('\n[2/2] Setting up user-level configuration...');
    try {
      await runCommand('bash', [setupScript]);
    } catch (err) {
      console.warn('Warning: User-level setup failed:', err.message);
      console.log('You can run it manually: bash', setupScript);
    }
  }

  console.log('\n=== Postinstall Complete ===\n');
}

main().catch((err) => {
  console.error('Postinstall error:', err);
  // Don't fail the install - just warn
  process.exit(0);
});
