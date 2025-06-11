/**
 * Tests for SORAORC-style launch script generation
 * Copyright 2024 Paul Preibisch
 */

import test from 'node:test'
import assert from 'node:assert'
import fs from 'fs-extra'
import path from 'path'
import { execSync } from 'child_process'
import { generateTeams } from '../src/generators/team-generator.js'
import { loadThemeByName } from '../src/themes/theme-loader.js'
import os from 'node:os'

const TEST_OUTPUT_DIR = path.join(process.cwd(), 'tests', 'launch-scripts-output')

test('SORAORC Launch Scripts', async (t) => {

  // Helper function to setup test directory
  const setupTestDir = async () => {
    await fs.ensureDir(TEST_OUTPUT_DIR)
    await fs.emptyDir(TEST_OUTPUT_DIR)
  }

  // Helper function to cleanup test directory
  const cleanupTestDir = async () => {
    try {
      await fs.remove(TEST_OUTPUT_DIR)
    } catch (error) {
      // Ignore cleanup errors
      console.error('Cleanup error:', error.message)
    }
  }

  // Wrapper function to handle setup and cleanup for each test
  const withTestDir = async (testName, testFn) => {
    await t.test(testName, async () => {
      await setupTestDir()
      try {
        await testFn()
      } finally {
        await cleanupTestDir()
      }
    })
  }

  await withTestDir('should generate individual agent launch scripts with correct content', async () => {
    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 1).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011 + index * 2,
        frontend: 5175 + index * 2
      },
      host: 'localhost',
      dockerNetwork: 'matrix-network'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    // Check individual agent launch script
    const agentDir = path.join(TEST_OUTPUT_DIR, 'agents', teams[0].id)
    const launchScript = path.join(agentDir, 'launch')
    
    assert.ok(await fs.pathExists(launchScript), 'Launch script should exist')
    
    const scriptContent = await fs.readFile(launchScript, 'utf8')
    
    // Verify basic script structure (individual agent scripts are simpler)
    assert.ok(scriptContent.includes('#!/bin/bash'), 'Should have bash shebang')
    assert.ok(scriptContent.includes(teams[0].name), 'Should include team name')
    assert.ok(scriptContent.includes(teams[0].ports.backend.toString()), 'Should include backend port')
    assert.ok(scriptContent.includes(teams[0].ports.frontend.toString()), 'Should include frontend port')
    
    // Verify script permissions
    const stats = await fs.stat(launchScript)
    assert.ok(stats.mode & 0o111, 'Launch script should be executable')
  })

  await withTestDir('should generate SORAORC-style orchestration scripts', async () => {
    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 2).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011 + index * 2,
        frontend: 5175 + index * 2
      },
      host: 'localhost',
      dockerNetwork: 'matrix-network'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    const scriptsDir = path.join(TEST_OUTPUT_DIR, 'scripts')
    
    // Check orchestration scripts exist
    const launchAllScript = path.join(scriptsDir, 'launch-all-teams.sh')
    const downAllScript = path.join(scriptsDir, 'down-all-teams.sh')
    const statusScript = path.join(scriptsDir, 'status-check.sh')
    
    assert.ok(await fs.pathExists(launchAllScript), 'Launch all script should exist')
    assert.ok(await fs.pathExists(downAllScript), 'Down all script should exist')
    assert.ok(await fs.pathExists(statusScript), 'Status check script should exist')
    
    // Verify permissions
    for (const script of [launchAllScript, downAllScript, statusScript]) {
      const stats = await fs.stat(script)
      assert.ok(stats.mode & 0o111, `${path.basename(script)} should be executable`)
    }
    
    // Check script content for SORAORC formatting
    const launchContent = await fs.readFile(launchAllScript, 'utf8')
    assert.ok(launchContent.includes('AGENTVIBES MULTI-AGENT ORCHESTRATOR'), 'Should include orchestrator branding')
    assert.ok(launchContent.includes('@997Fire'), 'Should include Twitter handle')
    assert.ok(launchContent.includes('├─'), 'Should include tree-style formatting')
    assert.ok(launchContent.includes('Teams to launch: 2'), 'Should show team count')
  })

  await withTestDir('should properly escape color variables in bash scripts', async () => {
    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 1).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011,
        frontend: 5175
      },
      host: 'localhost'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    const statusScript = path.join(TEST_OUTPUT_DIR, 'scripts', 'status-check.sh')
    const scriptContent = await fs.readFile(statusScript, 'utf8')
    
    // Verify color variables are properly defined for bash
    assert.ok(scriptContent.includes('RED=\'\\033[0;31m\''), 'RED variable should be properly defined')
    assert.ok(scriptContent.includes('GREEN=\'\\033[0;32m\''), 'GREEN variable should be properly defined')
    assert.ok(scriptContent.includes('NC=\'\\033[0m\''), 'NC variable should be properly defined')
    
    // Verify color variables are used correctly in echo statements  
    assert.ok(scriptContent.includes('\\${GREEN}'), 'GREEN should be used in echo statements')
    assert.ok(scriptContent.includes('\\${RED}'), 'RED should be used in echo statements')
    assert.ok(scriptContent.includes('\\${NC}'), 'NC should be used in echo statements')
    
    // Ensure no completely unescaped variable references that would cause errors
    assert.ok(!scriptContent.includes('${GREEN}') || scriptContent.includes('\\${GREEN}'), 'Color variables should be properly escaped')
    assert.ok(!scriptContent.includes('${RED}') || scriptContent.includes('\\${RED}'), 'Color variables should be properly escaped')
  })

  await withTestDir('should substitute all template variables correctly', async () => {
    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 1).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011,
        frontend: 5175,
        nginx: 3080
      },
      host: 'test.local',
      dockerNetwork: 'matrix-network'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    // Test orchestration script template substitution (where templates are actually used)
    const launchAllScript = path.join(TEST_OUTPUT_DIR, 'scripts', 'launch-all-teams.sh')
    const scriptContent = await fs.readFile(launchAllScript, 'utf8')
    
    // Verify basic template substitutions in orchestration scripts
    assert.ok(scriptContent.includes(teams[0].name), 'Agent name should be substituted')
    assert.ok(scriptContent.includes(teams[0].emoji), 'Agent emoji should be substituted')
    assert.ok(scriptContent.includes('3011'), 'Backend port should be substituted')
    assert.ok(scriptContent.includes('5175'), 'Frontend port should be substituted')
    assert.ok(scriptContent.includes('localhost'), 'Host should be substituted')
    assert.ok(scriptContent.includes('Teams to launch: 1'), 'Team count should be substituted')
    
    // Verify no unprocessed template variables remain
    assert.ok(!scriptContent.includes('{{'), 'No unprocessed template variables should remain')
    assert.ok(!scriptContent.includes('}}'), 'No unprocessed template variables should remain')
  })

  await withTestDir('should generate valid bash script syntax', async () => {
    // Skip bash syntax validation on Windows
    if (os.platform() === 'win32') {
      console.log('Skipping bash syntax validation on Windows')
      return
    }

    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 1).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011,
        frontend: 5175
      },
      host: 'localhost'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    // Test individual agent script
    const agentScript = path.join(TEST_OUTPUT_DIR, 'agents', teams[0].id, 'launch')
    
    // Use bash -n to validate syntax without executing
    try {
      execSync(`bash -n "${agentScript}"`, { stdio: 'pipe' })
    } catch (error) {
      assert.fail(`Agent launch script has invalid bash syntax: ${error.message}`)
    }

    // Test orchestration scripts
    const scriptsDir = path.join(TEST_OUTPUT_DIR, 'scripts')
    const scripts = ['launch-all-teams.sh', 'down-all-teams.sh', 'status-check.sh']
    
    for (const scriptName of scripts) {
      const scriptPath = path.join(scriptsDir, scriptName)
      try {
        execSync(`bash -n "${scriptPath}"`, { stdio: 'pipe' })
      } catch (error) {
        assert.fail(`${scriptName} has invalid bash syntax: ${error.message}`)
      }
    }
  })

  await withTestDir('should include proper SORAORC formatting elements', async () => {
    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 2).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011 + index * 2,
        frontend: 5175 + index * 2
      },
      host: 'localhost'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    const launchAllScript = path.join(TEST_OUTPUT_DIR, 'scripts', 'launch-all-teams.sh')
    const scriptContent = await fs.readFile(launchAllScript, 'utf8')
    
    // Verify SORAORC formatting elements
    assert.ok(scriptContent.includes('AGENTVIBES'), 'Should include AgentVibes branding')
    assert.ok(scriptContent.includes('v1.0'), 'Should include version number')
    assert.ok(scriptContent.includes('==============================================================================='), 'Should include ASCII headers')
    assert.ok(scriptContent.includes('├─'), 'Should include tree-style formatting')
    assert.ok(scriptContent.includes('└─'), 'Should include tree-style formatting (end)')
    assert.ok(scriptContent.includes('🔥'), 'Should include fire emoji for startup')
    assert.ok(scriptContent.includes('@997Fire'), 'Should include Twitter attribution')
    assert.ok(scriptContent.includes('https://github.com/paulpreibisch/AgentVibes'), 'Should include GitHub link')
    assert.ok(scriptContent.includes('💡 Powered by AgentVibes'), 'Should include powered by message')
  })

  await withTestDir('should handle port conflicts correctly', async () => {
    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 2).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011 + index * 2,
        frontend: 5175 + index * 2
      },
      host: 'localhost'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    // Individual agent scripts don't have complex port handling, check orchestration scripts
    const launchAllScript = path.join(TEST_OUTPUT_DIR, 'scripts', 'launch-all-teams.sh')
    const launchContent = await fs.readFile(launchAllScript, 'utf8')
    
    // Verify basic port references in orchestration
    assert.ok(launchContent.includes('3011'), 'Should reference backend port')
    assert.ok(launchContent.includes('5175'), 'Should reference frontend port')

    // Check orchestration scripts for cleanup
    const downAllScript = path.join(TEST_OUTPUT_DIR, 'scripts', 'down-all-teams.sh')
    const downContent = await fs.readFile(downAllScript, 'utf8')
    
    assert.ok(downContent.includes('lsof -ti:'), 'Should include port cleanup in down script')
    assert.ok(downContent.includes('xargs kill -9'), 'Should include forced process termination')
  })

  await withTestDir('should generate health check functionality', async () => {
    const theme = await loadThemeByName('matrix')
    const teams = theme.agents.slice(0, 1).map((agent, index) => ({
      ...agent,
      id: agent.name.toLowerCase().replace(/\s+/g, '-'),
      teamNumber: index + 1,
      theme: theme.name,
      themeEmoji: theme.emoji,
      ports: {
        backend: 3011,
        frontend: 5175
      },
      host: 'localhost'
    }))

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    // Check health check implementation in status script
    const statusScript = path.join(TEST_OUTPUT_DIR, 'scripts', 'status-check.sh')
    const statusContent = await fs.readFile(statusScript, 'utf8')
    
    // Verify health check logic
    assert.ok(statusContent.includes('curl -s http://localhost:3011/health'), 'Should check health endpoint')
    assert.ok(statusContent.includes('curl -s http://localhost:3011'), 'Should have fallback health check')
    assert.ok(statusContent.includes('> /dev/null 2>&1'), 'Should suppress curl output')
    assert.ok(statusContent.includes('RUNNING_COUNT'), 'Should track running services')
    assert.ok(statusContent.includes('✅ Running'), 'Should report healthy services')
    assert.ok(statusContent.includes('❌ Not running'), 'Should report unhealthy services')

    // Individual agent scripts have simple status reporting
    const agentScript = path.join(TEST_OUTPUT_DIR, 'agents', teams[0].id, 'launch')
    const agentContent = await fs.readFile(agentScript, 'utf8')
    
    assert.ok(agentContent.includes('ready at http://localhost:5175'), 'Should report frontend URL')
    assert.ok(agentContent.includes('Backend API at http://localhost:3011'), 'Should report backend URL')
  })

  await withTestDir('should handle multiple themes in orchestration scripts', async () => {
    // Load both Matrix and Anime themes
    const matrixTheme = await loadThemeByName('matrix')
    const animeTheme = await loadThemeByName('anime')
    
    const teams = [
      ...matrixTheme.agents.slice(0, 1).map((agent, index) => ({
        ...agent,
        id: agent.name.toLowerCase().replace(/\s+/g, '-'),
        teamNumber: index + 1,
        theme: matrixTheme.name,
        themeEmoji: matrixTheme.emoji,
        ports: {
          backend: 3011 + index * 2,
          frontend: 5175 + index * 2
        },
        host: 'localhost'
      })),
      ...animeTheme.agents.slice(0, 1).map((agent, index) => ({
        ...agent,
        id: agent.name.toLowerCase().replace(/\s+/g, '-'),
        teamNumber: index + 2,
        theme: animeTheme.name,
        themeEmoji: animeTheme.emoji,
        ports: {
          backend: 3013 + index * 2,
          frontend: 5177 + index * 2
        },
        host: 'localhost'
      }))
    ]

    const config = {
      teams,
      outputDir: TEST_OUTPUT_DIR,
      dryRun: false
    }

    await generateTeams(config)

    const launchAllScript = path.join(TEST_OUTPUT_DIR, 'scripts', 'launch-all-teams.sh')
    const scriptContent = await fs.readFile(launchAllScript, 'utf8')
    
    // Verify both themes are represented
    assert.ok(scriptContent.includes('Teams to launch: 2'), 'Should show correct team count')
    assert.ok(scriptContent.includes('(Matrix)'), 'Should include Matrix theme')
    assert.ok(scriptContent.includes('(Anime)'), 'Should include Anime theme')
    
    // Verify unique ports for each team
    assert.ok(scriptContent.includes('3011'), 'Should include Matrix backend port')
    assert.ok(scriptContent.includes('3013'), 'Should include Anime backend port')
    assert.ok(scriptContent.includes('5175'), 'Should include Matrix frontend port')
    assert.ok(scriptContent.includes('5177'), 'Should include Anime frontend port')
  })
})