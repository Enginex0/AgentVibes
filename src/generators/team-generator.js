/**
 * AgentVibes - Team generation core logic
 * Copyright 2024 Paul Preibisch
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 */

import path from 'path'
import { generateFolderStructure } from './folder-generator.js'
import { cloneRepository } from './repo-cloner.js'
import { generateConfigurations } from './config-generator.js'
import { generateCharacterConfig } from '../themes/character-manager.js'
import { logger } from '../utils/logger.js'
import { generateGitHubProjectsSetup } from '../utils/github-projects.js'

export async function generateTeams(config, progressCallback = () => {}) {
  const { teams, outputDir, repoUrl, authMethod, projectBoard, projectId, dryRun } = config
  
  if (!teams || teams.length === 0) {
    throw new Error('No teams specified for generation')
  }
  
  logger.info(`Generating ${teams.length} teams in ${outputDir}`)
  
  if (dryRun) {
    logger.info('DRY RUN MODE - No files will be created')
    await simulateGeneration(teams, config, progressCallback)
    return
  }
  
  try {
    // Group teams by theme for better progress reporting
    const teamsByTheme = groupTeamsByTheme(teams)
    
    let overallProgress = 0
    const totalSteps = teams.length * 5 // 5 steps per team
    let completedSteps = 0
    
    // Setup GitHub Projects if enabled
    let projectConfig = null
    if (projectBoard) {
      progressCallback({
        type: 'overall',
        progress: 0,
        message: { current: 'Setting up GitHub Projects board', next: 'Creating team directories' }
      })
      
      projectConfig = await generateGitHubProjectsSetup(config)
    }
    
    // Process each theme group
    for (const [themeName, themeTeams] of Object.entries(teamsByTheme)) {
      progressCallback({
        type: 'start',
        theme: { name: themeName, emoji: themeTeams[0].themeEmoji }
      })
      
      for (const team of themeTeams) {
        const teamNumber = teams.indexOf(team) + 1
        const characterConfig = generateCharacterConfig(team, 
          { name: themeName, emoji: team.themeEmoji, docker: { network: team.dockerNetwork || `${themeName.toLowerCase()}-network` } }, 
          teamNumber
        )
        
        // Step 1: Create folder structure
        progressCallback({
          type: 'task',
          theme: { name: themeName },
          task: 'folders',
          progress: 20,
          message: `Creating directories for ${team.name}`
        })
        
        await generateFolderStructure(outputDir, characterConfig)
        completedSteps++
        
        // Step 2: Clone repository
        if (repoUrl) {
          progressCallback({
            type: 'task',
            theme: { name: themeName },
            task: 'clone',
            progress: 40,
            message: `Cloning repository for ${team.name}`
          })
          
          await cloneRepository(repoUrl, path.join(outputDir, characterConfig.paths.root), {
            authMethod,
            agentName: team.name
          })
          completedSteps++
        } else {
          completedSteps++
        }
        
        // Step 3: Generate configurations
        progressCallback({
          type: 'task',
          theme: { name: themeName },
          task: 'config',
          progress: 60,
          message: `Generating configurations for ${team.name}`
        })
        
        try {
          await generateConfigurations(outputDir, characterConfig, {
            projectConfig,
            repoUrl
          })
        } catch (configError) {
          logger.error(`Configuration generation failed for ${team.name}:`, configError)
          progressCallback({
            type: 'task',
            theme: { name: themeName },
            task: 'config',
            progress: -1,
            message: `Failed to generate configurations for ${team.name}: ${configError.message}`
          })
          throw configError
        }
        
        completedSteps++
        
        // Update progress after config generation
        progressCallback({
          type: 'task',
          theme: { name: themeName },
          task: 'config',
          progress: 70,
          message: `Generated configurations for ${team.name}`
        })
        
        // Step 4: Setup git hooks
        progressCallback({
          type: 'task',
          theme: { name: themeName },
          task: 'git',
          progress: 80,
          message: `Setting up git hooks for ${team.name}`
        })
        
        await setupGitHooks(outputDir, characterConfig)
        completedSteps++
        
        // Step 5: Final setup
        progressCallback({
          type: 'task',
          theme: { name: themeName },
          task: 'final',
          progress: 100,
          message: `Completed setup for ${team.name}`
        })
        completedSteps++
        
        // Update overall progress
        overallProgress = Math.round((completedSteps / totalSteps) * 100)
        progressCallback({
          type: 'overall',
          progress: overallProgress,
          message: {
            current: `Completed ${team.name}`,
            next: completedSteps < totalSteps ? 'Setting up next agent' : 'Finalizing setup'
          }
        })
      }
      
      progressCallback({
        type: 'complete',
        theme: { name: themeName, emoji: themeTeams[0].themeEmoji }
      })
    }
    
    // Generate docker-compose files for each theme
    await generateDockerComposeFiles(outputDir, teamsByTheme)
    
    // Generate launch scripts
    await generateLaunchScripts(outputDir, teams)
    
    logger.success('All teams generated successfully!')
    
  } catch (error) {
    progressCallback({
      type: 'error',
      message: error.message
    })
    throw error
  }
}

function groupTeamsByTheme(teams) {
  return teams.reduce((groups, team) => {
    const theme = team.theme || 'default'
    if (!groups[theme]) {
      groups[theme] = []
    }
    groups[theme].push(team)
    return groups
  }, {})
}

async function setupGitHooks(outputDir, characterConfig) {
  const fs = (await import('fs-extra')).default
  const gitHooksPath = path.join(outputDir, characterConfig.paths.gitHooks)
  
  await fs.ensureDir(gitHooksPath)
  
  // Prepare commit message hook
  const prepareCommitMsg = `#!/bin/bash
# Prepend emoji to commit messages
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2
if [ -z "$COMMIT_SOURCE" ]; then
  # Only for regular commits, not merges/amends
  echo "${characterConfig.emoji} ${characterConfig.name}: $(cat $COMMIT_MSG_FILE)" > $COMMIT_MSG_FILE
fi`
  
  await fs.writeFile(
    path.join(gitHooksPath, 'prepare-commit-msg'),
    prepareCommitMsg,
    { mode: 0o755 }
  )
  
  // Commit message validation hook
  const commitMsg = `#!/bin/bash
# Ensure emoji is present
COMMIT_MSG_FILE=$1
if ! grep -q "^${characterConfig.emoji}" "$COMMIT_MSG_FILE"; then
  echo "${characterConfig.emoji} ${characterConfig.name}: $(cat $COMMIT_MSG_FILE)" > $COMMIT_MSG_FILE
fi`
  
  await fs.writeFile(
    path.join(gitHooksPath, 'commit-msg'),
    commitMsg,
    { mode: 0o755 }
  )
}

async function generateDockerComposeFiles(outputDir, teamsByTheme) {
  const fs = (await import('fs-extra')).default
  const dockerDir = path.join(outputDir, 'docker')
  await fs.ensureDir(dockerDir)
  
  for (const [themeName, teams] of Object.entries(teamsByTheme)) {
    const services = {}
    
    teams.forEach(team => {
      const serviceName = team.id
      services[serviceName] = {
        build: {
          context: `../agents/${team.id}`,
          dockerfile: 'Dockerfile'
        },
        container_name: `${themeName.toLowerCase()}-${team.id}`,
        ports: [
          `${team.ports.backend}:${team.ports.backend}`,
          `${team.ports.frontend}:${team.ports.frontend}`
        ],
        environment: {
          NODE_ENV: 'development',
          AGENT_NAME: team.name,
          AGENT_EMOJI: team.emoji,
          BACKEND_PORT: team.ports.backend,
          FRONTEND_PORT: team.ports.frontend
        },
        networks: [team.dockerNetwork || `${themeName.toLowerCase()}-network`],
        volumes: [
          `${team.id}_data:/app/data`,
          `${team.id}_logs:/app/logs`
        ],
        restart: 'unless-stopped'
      }
    })
    
    const compose = {
      version: '3.8',
      services,
      networks: {
        [teams[0].dockerNetwork || `${themeName.toLowerCase()}-network`]: {
          driver: 'bridge'
        }
      },
      volumes: teams.reduce((vols, team) => {
        vols[`${team.id}_data`] = {}
        vols[`${team.id}_logs`] = {}
        return vols
      }, {})
    }
    
    await fs.writeFile(
      path.join(dockerDir, `docker-compose.${themeName.toLowerCase()}.yml`),
      `# Docker Compose for ${themeName} theme
# Generated by Agentic Team Generator
      
${JSON.stringify(compose, null, 2).replace(/"/g, '')}`
    )
  }
}

async function generateLaunchScripts(outputDir, teams) {
  const fs = (await import('fs-extra')).default
  const scriptsDir = path.join(outputDir, 'scripts')
  await fs.ensureDir(scriptsDir)
  
  // Launch all teams script
  const launchAll = `#!/bin/bash
# Launch all agentic teams
echo "🚀 Launching all agentic teams..."

${teams.map(team => `
echo "Starting ${team.emoji} ${team.name}..."
cd agents/${team.id} && ./launch &
`).join('')}

echo "✅ All teams launched!"
echo "Check status with: ./scripts/status-check.sh"
`
  
  await fs.writeFile(
    path.join(scriptsDir, 'launch-all-teams.sh'),
    launchAll,
    { mode: 0o755 }
  )
  
  // Down all teams script
  const downAll = `#!/bin/bash
# Stop all agentic teams
echo "🛑 Stopping all agentic teams..."

${teams.map(team => `
echo "Stopping ${team.emoji} ${team.name}..."
cd agents/${team.id} && ./down
`).join('')}

echo "✅ All teams stopped!"
`
  
  await fs.writeFile(
    path.join(scriptsDir, 'down-all-teams.sh'),
    downAll,
    { mode: 0o755 }
  )
  
  // Status check script
  const statusCheck = `#!/bin/bash
# Check status of all teams
echo "📊 Team Status Check"
echo "===================="

${teams.map(team => `
echo -n "${team.emoji} ${team.name}: "
if curl -s http://localhost:${team.ports.backend}/health > /dev/null; then
  echo "✅ Running"
else
  echo "❌ Not running"
fi
`).join('')}
`
  
  await fs.writeFile(
    path.join(scriptsDir, 'status-check.sh'),
    statusCheck,
    { mode: 0o755 }
  )
}

async function simulateGeneration(teams, config, progressCallback) {
  // Dry run simulation
  logger.info('\n=== DRY RUN RESULTS ===\n')
  logger.info('The following would be created:')
  
  // Call progress callback to indicate start
  progressCallback({
    type: 'start',
    theme: { name: 'All Themes', emoji: '🎭' }
  })
  
  teams.forEach((team, index) => {
    logger.info(`\n${team.emoji} ${team.name}:`)
    logger.info(`  - Directory: agents/${team.id}/`)
    logger.info(`  - CLAUDE.md with personality traits`)
    logger.info(`  - .mcp.json configuration`)
    logger.info(`  - Git hooks for emoji commits`)
    logger.info(`  - Ports: Backend ${team.ports.backend}, Frontend ${team.ports.frontend}`)
    if (config.repoUrl) {
      logger.info(`  - Clone repository: ${config.repoUrl}`)
    }
  })
  
  logger.info('\nDocker compose files for each theme')
  logger.info('Launch scripts in scripts/')
  
  if (config.projectBoard) {
    logger.info('\nGitHub Projects board with automation')
  }
  
  logger.info('\n=== END DRY RUN ===\n')
}