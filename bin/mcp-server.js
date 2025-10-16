#!/usr/bin/env node

/**
 * AgentVibes MCP Server Launcher (Cross-Platform)
 *
 * This Node.js script replaces the bash wrapper to work on Windows, macOS, and Linux.
 * It auto-installs Python dependencies and launches the Python MCP server.
 */

import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { existsSync } from 'fs';
import { platform } from 'os';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Package root is one level up from bin/
const PACKAGE_ROOT = join(__dirname, '..');
const MCP_SERVER = join(PACKAGE_ROOT, 'mcp-server', 'server.py');
const INSTALL_DEPS = join(PACKAGE_ROOT, 'mcp-server', 'install-deps.js');

// Check if Python MCP server exists
if (!existsSync(MCP_SERVER)) {
  console.error(`❌ Error: MCP server not found at ${MCP_SERVER}`);
  process.exit(1);
}

// Function to check if a command exists
function commandExists(command) {
  return new Promise((resolve) => {
    const cmd = platform() === 'win32' ? 'where' : 'which';
    const proc = spawn(cmd, [command], { stdio: 'ignore' });
    proc.on('close', (code) => resolve(code === 0));
  });
}

// Function to check if Python module is installed
function checkPythonModule(moduleName) {
  return new Promise((resolve) => {
    const proc = spawn('python3', ['-c', `import ${moduleName}`], { stdio: 'ignore' });
    proc.on('close', (code) => resolve(code === 0));
  });
}

// Main setup and launch function
async function main() {
  console.error('🚀 Starting AgentVibes MCP Server...');

  // Check for Python 3
  const hasPython = await commandExists('python3');
  if (!hasPython) {
    console.error('\n❌ Python 3 Not Found');
    console.error('AgentVibes MCP server requires Python 3.10 or newer.');
    console.error('');
    console.error('📖 Install Python:');
    console.error('   Windows: https://python.org');
    console.error('   macOS:   brew install python3');
    console.error('   Linux:   sudo apt install python3');
    console.error('');
    console.error('💡 After installing Python, restart Claude Desktop');
    process.exit(1);
  }

  console.error('✅ Python 3 detected');

  // Check if MCP Python package is installed
  const hasMCP = await checkPythonModule('mcp');
  if (!hasMCP) {
    console.error('\n📦 Installing Python MCP package...');

    // Run the install-deps script
    if (existsSync(INSTALL_DEPS)) {
      const installProc = spawn('node', [INSTALL_DEPS], {
        stdio: 'inherit',
        shell: true
      });

      await new Promise((resolve, reject) => {
        installProc.on('close', (code) => {
          if (code === 0) {
            console.error('✅ Python dependencies installed');
            resolve();
          } else {
            console.error('❌ Failed to install Python dependencies');
            reject(new Error('Dependency installation failed'));
          }
        });
      });
    }
  } else {
    console.error('✅ Python MCP package already installed');
  }

  // Check for ELEVENLABS_API_KEY if needed
  if (process.env.ELEVENLABS_API_KEY) {
    console.error('✅ ElevenLabs API key configured');
  } else {
    console.error('⚠️  ELEVENLABS_API_KEY not set (Piper TTS will be used)');
  }

  console.error('\n🎤 Launching MCP server...\n');

  // Launch the Python MCP server
  const serverProc = spawn('python3', [MCP_SERVER], {
    stdio: 'inherit',
    env: process.env
  });

  serverProc.on('error', (err) => {
    console.error('❌ Failed to start MCP server:', err.message);
    process.exit(1);
  });

  serverProc.on('close', (code) => {
    process.exit(code || 0);
  });

  // Handle termination signals
  process.on('SIGINT', () => serverProc.kill('SIGINT'));
  process.on('SIGTERM', () => serverProc.kill('SIGTERM'));
}

main().catch((err) => {
  console.error('❌ Error:', err.message);
  process.exit(1);
});
