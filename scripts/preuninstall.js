#!/usr/bin/env node
/**
 * AgentVibes Preuninstall Script
 *
 * Runs before npm uninstall to:
 * 1. Remove MCP configuration (aggregator or direct)
 * 2. Stop and remove systemd service
 * 3. Clean up AgentVibes-specific files
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
  console.log('\n=== AgentVibes Preuninstall ===\n');

  const uninstallScript = join(rootDir, 'scripts', 'uninstall-user-level.sh');

  if (existsSync(uninstallScript)) {
    console.log('Running uninstall cleanup...');
    try {
      await runCommand('bash', [uninstallScript]);
    } catch (err) {
      console.warn('Warning: Uninstall cleanup had issues:', err.message);
      // Don't fail the uninstall - just warn
    }
  } else {
    console.log('Uninstall script not found, skipping cleanup');
  }

  console.log('\n=== Preuninstall Complete ===\n');
}

main().catch((err) => {
  console.error('Preuninstall error:', err);
  // Don't fail the uninstall - just warn
  process.exit(0);
});
