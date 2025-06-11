import { test, describe } from 'node:test'
import assert from 'node:assert'
import fs from 'fs-extra'
import path from 'path'
import { fileURLToPath } from 'url'
import { generateCharacterConfig, generateTeamIdentity, interpolatePersonality } from '../src/themes/character-manager.js'
import { generateConfigurations } from '../src/generators/config-generator.js'
import { generateFolderStructure } from '../src/generators/folder-generator.js'
import { generateTeams } from '../src/generators/team-generator.js'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

describe('Generators', () => {
  const testDir = path.join(__dirname, 'temp-test')
  
  async function setupTestDir() {
    await fs.ensureDir(testDir)
  }
  
  async function cleanupTestDir() {
    await fs.remove(testDir)
  }

  test('should generate character configuration with all properties', () => {
    const agent = {
      id: 'neo',
      name: 'Neo',
      emoji: '🕶️',
      description: 'The One who will save humanity',
      personality: {
        traits: ['questioning', 'determined', 'chosen'],
        catchphrases: ['Whoa', 'There is no spoon', 'I know kung fu'],
        communication_style: 'philosophical and questioning'
      },
      ports: {
        backend: 3011,
        frontend: 5175,
        nginx: 3080
      },
      host: 'neo.matrix.test'
    }
    
    const theme = {
      name: 'Matrix',
      emoji: '🕶️',
      docker: { network: 'matrix-network' }
    }
    
    const config = generateCharacterConfig(agent, theme, 1)
    
    // Basic properties
    assert.strictEqual(config.id, 'neo')
    assert.strictEqual(config.name, 'Neo')
    assert.strictEqual(config.emoji, '🕶️')
    assert.strictEqual(config.teamNumber, 1)
    assert.strictEqual(config.theme, 'Matrix')
    assert.strictEqual(config.themeEmoji, '🕶️')
    assert.strictEqual(config.description, 'The One who will save humanity')
    
    // Personality should be enhanced (with possible signature)
    assert.strictEqual(config.personality.traits.length, 3)
    assert.strictEqual(config.personality.catchphrases.length, 3)
    assert(config.personality.signature === null || typeof config.personality.signature === 'string')
    
    // Docker configuration
    assert.strictEqual(config.docker.containerName, 'matrix-neo')
    assert.strictEqual(config.docker.network, 'matrix-network')
    assert.strictEqual(config.docker.volumes.data, 'neo_data')
    assert.strictEqual(config.docker.volumes.logs, 'neo_logs')
    
    // Paths configuration
    assert.strictEqual(config.paths.root, 'agents/neo')
    assert.strictEqual(config.paths.claude, 'agents/neo/CLAUDE.md')
    assert.strictEqual(config.paths.mcp, 'agents/neo/.mcp.json')
    assert.strictEqual(config.paths.commands, 'agents/neo/.claude/commands')
    assert.strictEqual(config.paths.gitHooks, 'agents/neo/.git/hooks')
    
    // Ports should be copied
    assert.deepStrictEqual(config.ports, agent.ports)
    assert.strictEqual(config.host, 'neo.matrix.test')
  })
  
  test('should handle agent without optional fields', () => {
    const minimalAgent = {
      id: 'minimal',
      name: 'Minimal Agent',
      emoji: '🤖',
      personality: {
        traits: ['simple'],
        catchphrases: ['Hello'],
        communication_style: 'basic'
      },
      ports: {
        backend: 3000,
        frontend: 5000,
        nginx: 3080
      },
      host: 'minimal.test'
    }
    
    const theme = {
      name: 'Test',
      emoji: '🧪',
      docker: { network: 'test-network' }
    }
    
    const config = generateCharacterConfig(minimalAgent, theme, 1)
    
    // Should have defaults for missing fields
    assert(config.description === undefined || config.description === '')
    assert(config.paths.root === 'agents/minimal')
  })

  test('should generate team identity with correct prefixes', () => {
    const agent = {
      name: 'Neo',
      emoji: '🕶️',
      personality: {
        catchphrases: ['Whoa', 'There is no spoon']
      }
    }
    
    const theme = { name: 'Matrix' }
    const teamNumber = 1
    
    const identity = generateTeamIdentity(agent, theme, teamNumber)
    
    // Check greeting format
    assert(identity.greeting.includes('🕶️ Neo says: "Whoa"'))
    
    // Check all prefixes
    assert.strictEqual(identity.commitPrefix, '🕶️ Neo:')
    assert.strictEqual(identity.issuePrefix, '🕶️ Team-1:')
    assert.strictEqual(identity.prPrefix, '🕶️ Team-1:')
    assert.strictEqual(identity.commentPrefix, '🕶️ Neo says:')
  })
  
  test('should handle agent with no catchphrases', () => {
    const agent = {
      name: 'Silent Bob',
      emoji: '🤐',
      personality: {
        catchphrases: []
      }
    }
    
    const identity = generateTeamIdentity(agent, { name: 'Test' }, 1)
    
    // Should use default catchphrase
    assert(identity.greeting.includes("Let's code!"))
  })

  test('should interpolate all personality variables correctly', () => {
    const template = `Agent: {{agentName}} {{agentEmoji}}
Team: {{teamNumber}} - {{teamDescription}}
Traits: {{personality.traits}}
Catchphrases: {{personality.catchphrases}}
Style: {{personality.communication_style}}
Theme: {{theme}} {{themeEmoji}}
Ports: {{ports.backend}}/{{ports.frontend}}/{{ports.nginx}}
Docker: {{containerName}} on {{dockerNetwork}}
Host: {{hostName}}`
    
    const character = {
      name: 'Neo',
      emoji: '🕶️',
      teamNumber: 1,
      description: 'The One',
      theme: 'Matrix',
      themeEmoji: '🕶️',
      personality: {
        traits: ['questioning', 'determined'],
        catchphrases: ['Whoa', 'There is no spoon'],
        communication_style: 'philosophical'
      },
      ports: {
        backend: 3011,
        frontend: 5175,
        nginx: 3080
      },
      host: 'neo.test',
      docker: {
        containerName: 'matrix-neo',
        network: 'matrix-network'
      }
    }
    
    const result = interpolatePersonality(template, character)
    
    // Verify all interpolations
    assert(result.includes('Agent: Neo 🕶️'))
    assert(result.includes('Team: 1 - The One'))
    assert(result.includes('Traits: questioning, determined'))
    assert(result.includes('Catchphrases: "Whoa", "There is no spoon"'))
    assert(result.includes('Style: philosophical'))
    assert(result.includes('Theme: Matrix 🕶️'))
    assert(result.includes('Ports: 3011/5175/3080'))
    assert(result.includes('Docker: matrix-neo on matrix-network'))
    assert(result.includes('Host: neo.test'))
  })
  
  test('should not interpolate undefined variables', () => {
    const template = 'Name: {{agentName}}, Unknown: {{unknownVariable}}'
    const character = { 
      name: 'Test',
      personality: {
        traits: ['test'],
        catchphrases: ['test'],
        communication_style: 'test'
      },
      ports: {
        backend: 3000,
        frontend: 5000,
        nginx: 3080
      },
      docker: {
        containerName: 'test-container',
        network: 'test-network'
      },
      host: 'test.local'
    }
    
    const result = interpolatePersonality(template, character)
    
    assert(result.includes('Name: Test'))
    assert(result.includes('Unknown: {{unknownVariable}}'), 'Unknown variables should remain unchanged')
  })

  test('should generate folder structure correctly', async () => {
    await setupTestDir()
    
    const config = {
      id: 'test-agent',
      paths: {
        root: 'agents/test-agent',
        commands: 'agents/test-agent/.claude/commands'
      }
    }
    
    await generateFolderStructure(testDir, config)
    
    // Check all directories were created
    assert(await fs.pathExists(path.join(testDir, 'agents/test-agent')))
    assert(await fs.pathExists(path.join(testDir, 'agents/test-agent/.claude')))
    assert(await fs.pathExists(path.join(testDir, 'agents/test-agent/.claude/commands')))
    
    await cleanupTestDir()
  })

  test('should generate configurations with all files', async () => {
    await setupTestDir()
    
    const characterConfig = {
      id: 'test-agent',
      name: 'Test Agent',
      emoji: '🧪',
      teamNumber: 1,
      theme: 'Test',
      themeEmoji: '🧪',
      description: 'A test agent',
      personality: {
        traits: ['testing'],
        catchphrases: ['Testing!'],
        communication_style: 'precise',
        signature: null
      },
      ports: {
        backend: 3011,
        frontend: 5175,
        nginx: 3080
      },
      host: 'test.local',
      docker: {
        containerName: 'test-container',
        network: 'test-network'
      },
      paths: {
        root: 'agents/test-agent',
        claude: 'agents/test-agent/CLAUDE.md',
        mcp: 'agents/test-agent/.mcp.json',
        commands: 'agents/test-agent/.claude/commands',
        gitHooks: 'agents/test-agent/.git/hooks'
      }
    }
    
    await generateConfigurations(testDir, characterConfig, {
      repoUrl: 'https://github.com/test/repo.git'
    })
    
    // Check all files were created
    const agentDir = path.join(testDir, 'agents/test-agent')
    assert(await fs.pathExists(path.join(agentDir, 'CLAUDE.md')))
    assert(await fs.pathExists(path.join(agentDir, '.mcp.json')))
    assert(await fs.pathExists(path.join(agentDir, 'launch')))
    assert(await fs.pathExists(path.join(agentDir, 'down')))
    assert(await fs.pathExists(path.join(agentDir, 'build.sh')))
    assert(await fs.pathExists(path.join(agentDir, 'Dockerfile')))
    assert(await fs.pathExists(path.join(agentDir, '.env')))
    
    // Verify file contents
    const claudeMd = await fs.readFile(path.join(agentDir, 'CLAUDE.md'), 'utf-8')
    assert(claudeMd.includes('Test Agent'))
    assert(claudeMd.includes('🧪'))
    assert(claudeMd.includes('Team 1'))
    
    const mcpJson = await fs.readJson(path.join(agentDir, '.mcp.json'))
    assert.strictEqual(mcpJson.name, 'Test Agent Agent')
    assert.strictEqual(mcpJson.emoji, '🧪')
    assert.deepStrictEqual(mcpJson.personality.traits, ['testing'])
    
    const envFile = await fs.readFile(path.join(agentDir, '.env'), 'utf-8')
    assert(envFile.includes('AGENT_NAME=Test Agent'))
    assert(envFile.includes('REPO_URL=https://github.com/test/repo.git'))
    
    // Check script permissions
    const launchStats = await fs.stat(path.join(agentDir, 'launch'))
    assert(launchStats.mode & 0o111, 'launch script should be executable')
    
    await cleanupTestDir()
  })

  test('should handle configuration generation errors gracefully', async () => {
    const invalidConfig = {
      id: 'test',
      name: 'Test',
      personality: {
        traits: ['test'],
        catchphrases: ['test'],
        communication_style: 'test'
      },
      paths: {
        root: '/invalid/path/that/cannot/be/created',
        claude: '/invalid/CLAUDE.md'
      }
    }
    
    await assert.rejects(
      async () => await generateConfigurations('/root', invalidConfig),
      Error
    )
  })

  test('should generate teams with progress callback', async () => {
    await setupTestDir()
    
    const progressUpdates = []
    
    const config = {
      teams: [{
        id: 'test-agent',
        name: 'Test Agent',
        emoji: '🧪',
        theme: 'Test',
        themeEmoji: '🧪',
        personality: {
          traits: ['testing'],
          catchphrases: ['Test!'],
          communication_style: 'precise'
        },
        ports: {
          backend: 3011,
          frontend: 5175,
          nginx: 3080
        },
        host: 'test.local'
      }],
      outputDir: testDir,
      dryRun: true
    }
    
    await generateTeams(config, (progress) => {
      progressUpdates.push(progress)
    })
    
    // Verify progress callbacks were made
    assert(progressUpdates.some(p => p.type === 'start'))
    // In dry-run mode, we might not get all progress types
    assert(progressUpdates.length > 0, 'Should have at least one progress update')
    
    // Should not create actual files in dry-run
    assert(!await fs.pathExists(path.join(testDir, 'agents')))
    
    await cleanupTestDir()
  })

  test('should reject teams with invalid configuration', async () => {
    await setupTestDir()
    
    const config = {
      teams: null, // Invalid
      outputDir: testDir
    }
    
    await assert.rejects(
      async () => await generateTeams(config),
      /No teams specified for generation/
    )
    
    await cleanupTestDir()
  })

  test('should generate correct docker-compose structure', async () => {
    await setupTestDir()
    
    const config = {
      teams: [
        {
          id: 'neo',
          name: 'Neo',
          emoji: '🕶️',
          theme: 'Matrix',
          themeEmoji: '🕶️',
          ports: { backend: 3011, frontend: 5175 },
          dockerNetwork: 'matrix-network',
          personality: {
            traits: ['test'],
            catchphrases: ['test'],
            communication_style: 'test'
          },
          host: 'neo.test'
        }
      ],
      outputDir: testDir
    }
    
    await generateTeams(config, () => {})
    
    // Check docker-compose file was created
    const dockerComposeFile = path.join(testDir, 'docker/docker-compose.matrix.yml')
    assert(await fs.pathExists(dockerComposeFile))
    
    const content = await fs.readFile(dockerComposeFile, 'utf-8')
    assert(content.includes('matrix-neo'))
    assert(content.includes('3011:3011'))
    
    await cleanupTestDir()
  })
})