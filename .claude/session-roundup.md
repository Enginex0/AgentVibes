# AgentVibes Session Roundup

**Date:** December 14, 2025
**Status:** MCP Default + Auto-Install Complete

---

## Quick Context for Next Session

AgentVibes is a TTS (Text-to-Speech) system for Claude Code. This session:

1. **Made MCP the default TTS mode** - faster than Bash (~50-100ms vs ~160-290ms)
2. **Implemented zero-delay symlink switching** - no runtime checks
3. **Updated MCP server** to use file queue instead of old FIFO
4. **Added auto voice download** to installer (60MB model)
5. **Fixed uninstaller** to clean all traces (was missing 7+ items)
6. **Pushed all changes** to GitHub

---

## Commits This Session

```
3af067f3 fix(installer): Auto-download voice model + complete uninstall cleanup
abe795b0 feat(tts): MCP as default with zero-delay symlink switching
```

---

## Architecture: MCP vs Bash TTS

```
~/.claude/hooks/
├── session-start-bash-tts.sh     # Bash version (fallback)
├── session-start-mcp-tts.sh      # MCP version (default, faster)
└── session-start-tts.sh → symlink (kernel-resolved, zero overhead)
```

**Installer logic:**
- If aggregator detected + MCP configured → symlink to MCP
- If no aggregator → symlink to Bash

**Performance:**
| Mode | Latency |
|------|---------|
| MCP | ~50-100ms |
| Bash | ~160-290ms |

---

## Key Files Modified

| File | Changes |
|------|---------|
| `.claude/hooks/session-start-bash-tts.sh` | Renamed from session-start-tts.sh |
| `.claude/hooks/session-start-mcp-tts.sh` | Full features (verbosity, logging) |
| `.claude/hooks/tts-mode-toggle.sh` | NEW - manual mode switching |
| `mcp-server/server.py` | Updated to use file queue |
| `scripts/install-user-level.sh` | +Auto voice download, +12 steps |
| `scripts/uninstall-user-level.sh` | +7 cleanup items |

---

## Git Status

```
Branch: master
Origin: github.com/Enginex0/AgentVibes
Latest commit: 3af067f3 fix(installer): Auto-download voice model
Pushed: Yes
Commits ahead of upstream: 29
```

---

## Installer Now Handles (Zero User Intervention)

1. Directory structure
2. Hooks (51 scripts)
3. Personalities (21 files)
4. Slash commands (56 files)
5. Daemon scripts
6. Audio assets
7. MCP server
8. Default config
9. **Voice model download (NEW - 60MB)**
10. Systemd service
11. MCP aggregator config
12. **TTS mode symlink (NEW - MCP default)**

---

## Next Session

Potential work:
- Test fresh install on clean system
- Upstream PR to original AgentVibes repo
- Additional voice models
- Further optimizations if needed
