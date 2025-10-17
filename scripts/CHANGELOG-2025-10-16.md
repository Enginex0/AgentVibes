# Audio Tunnel Fix - October 16, 2025

## Summary

Fixed critical audio tunnel issues where AgentVibes TTS stopped working between ubuntu-rdp and Windows WSL. The root cause was stale SSH processes holding port 14713, combined with a stopped socat bridge.

## What Happened

### User Report
> "Audio on this computer is not even working for Agent Vibes"
> "speaker-test -t sine -f 1000 -l 1" fails with "Connection refused"
> "This was working just yesterday"

### Investigation

**Initial Symptoms:**
```bash
$ speaker-test -t sine -f 1000 -l 1
ALSA lib pulse.c:242:(pulse_connect) PulseAudio: Unable to connect: Connection terminated
Playback open error: -111,Connection refused
```

**SSH Tunnel Warnings:**
```
Warning: remote port forwarding failed for listen port 14713
```

### Root Cause Analysis

**Primary Issue:** Multiple stale SSH processes on ubuntu-rdp were holding port 14713
```bash
$ sudo lsof -i :14713
COMMAND     PID          USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
sshd    2845015 administrator    7u  IPv6 70604344      0t0  TCP ip6-localhost:14713 (LISTEN)
sshd    2845015 administrator    9u  IPv4 70604345      0t0  TCP localhost:14713 (LISTEN)
```

**Secondary Issue:** socat bridge on WSL had stopped running
```bash
$ wsl ss -tlnp | grep 14713
# No output - socat not running!
```

### Why This Happened

1. **Zombie SSH Sessions**: Previous SSH connections didn't terminate cleanly, leaving processes bound to port 14713
2. **Background Job Termination**: The socat bridge PowerShell background job had ended
3. **No Automatic Recovery**: No healthcheck or recovery mechanism existed

## The Fix

### Steps Performed

1. **Identified stale processes:**
   ```bash
   ssh ubuntu-rdp 'sudo lsof -i :14713'
   ```

2. **Forcefully killed them:**
   ```bash
   ssh ubuntu-rdp 'sudo fuser -k 14713/tcp'
   ```

3. **Restarted socat bridge:**
   ```powershell
   wsl pkill socat
   Start-Job -ScriptBlock {
     wsl socat 'TCP-LISTEN:14713,fork,reuseaddr' 'UNIX-CONNECT:/mnt/wslg/PulseServer'
   } -Name "SocatAudioBridge"
   ```

4. **Created fresh SSH tunnel:**
   ```bash
   wsl bash -c "ssh -f -N -R 14713:localhost:14713 ubuntu-rdp"
   ```

5. **Verified connection:**
   ```bash
   ssh ubuntu-rdp 'netstat -tlnp | grep 14713'
   # Output showed tunnel was listening
   ```

### Result
✅ Audio tunnel restored
✅ AgentVibes TTS working through Windows speakers
✅ speaker-test playing sound successfully

## Improvements Made

### 1. Updated fix-audio-tunnel.sh Script

**New Features:**
- ✅ Auto-detects environment (WSL vs ubuntu-rdp)
- ✅ Kills stale SSH processes on remote server automatically
- ✅ Restarts socat bridge if stopped
- ✅ Kills local stale SSH tunnels
- ✅ Creates fresh tunnel with verification
- ✅ Tests audio connection
- ✅ Provides clear status messages and instructions

**Script Locations:**
- `scripts/fix-audio-tunnel.sh` (main script)
- `scripts/fix-audio-tunnel-complete.sh` (backup)

### 2. Created TROUBLESHOOTING.md

Comprehensive troubleshooting guide documenting:
- Root cause analysis of today's issue
- Audio tunnel architecture diagram
- Common symptoms and solutions
- Diagnostic command reference
- Prevention best practices
- Success indicators

### 3. Updated scripts/README.md

Added documentation for:
- `fix-audio-tunnel.sh` usage and features
- Quick fix guide
- Common issues and their fixes
- Manual diagnostic commands
- Reference to TROUBLESHOOTING.md

## Technical Details

### Audio Tunnel Architecture

```
ubuntu-rdp (Remote)           WSL (Windows)                Windows
    │                              │                          │
    │ Speaker-test/TTS             │                          │
    │         ↓                    │                          │
    │  PULSE_SERVER=              │                          │
    │  tcp:localhost:14713         │                          │
    │         ↓                    │                          │
    │  [SSH Tunnel Port 14713] ←──┴──→ [socat Bridge]        │
    │                              │      ↓                   │
    │                              │  TCP:14713 →            │
    │                              │  UNIX:/mnt/wslg/        │
    │                              │  PulseServer            │
    │                              │      ↓                   │
    │                              │  [WSL PulseAudio] ───→ Speakers
```

### Key Commands

**Diagnostic:**
```bash
# Check socat bridge
wsl ss -tlnp | grep 14713

# Check SSH tunnel
ssh ubuntu-rdp 'netstat -tlnp | grep 14713'

# Find stale processes
ssh ubuntu-rdp 'sudo lsof -i :14713'

# Test PulseAudio
ssh ubuntu-rdp 'export PULSE_SERVER=tcp:localhost:14713 && pactl info'
```

**Fix:**
```bash
# Automated fix (recommended)
./scripts/fix-audio-tunnel.sh

# Manual fix
ssh ubuntu-rdp 'sudo fuser -k 14713/tcp'
wsl pkill socat
wsl bash -c "ssh -f -N -R 14713:localhost:14713 ubuntu-rdp"
```

## Prevention

### Recommendations Implemented

1. **Automated recovery script**: `fix-audio-tunnel.sh` handles all common failure modes
2. **Environment detection**: Script adapts to whether it's run from WSL or ubuntu-rdp
3. **Comprehensive diagnostics**: Script reports status at each step
4. **Documentation**: TROUBLESHOOTING.md provides detailed incident analysis

### Future Improvements

1. **Healthcheck cron job**: Periodically verify tunnel status
2. **Auto-restart on failure**: systemd service or scheduled task
3. **Monitoring alert**: Notify when tunnel goes down
4. **Persistent socat**: Run as systemd service instead of background job

## Lessons Learned

1. **Always check for stale processes first** - `sudo lsof -i :14713` should be the first diagnostic
2. **Force kill is sometimes necessary** - Regular termination may not release port bindings
3. **socat bridge is critical** - Even with a working tunnel, audio fails if socat isn't running
4. **Background jobs don't persist** - Need better solution for long-running processes
5. **Document immediately** - Capture troubleshooting steps while fresh

## Testing Performed

### Before Fix
```bash
$ speaker-test -t sine -f 1000 -l 1
Playback open error: -111,Connection refused
```

### After Fix
```bash
$ speaker-test -t sine -f 1000 -l 1
# Audio played through Windows speakers successfully
```

### Verification
```bash
$ ssh ubuntu-rdp 'export PULSE_SERVER=tcp:localhost:14713 && pactl info | head -3'
Server String: tcp:localhost:14713
Library Protocol Version: 35
Server Protocol Version: 35
```

## Files Modified

- `scripts/fix-audio-tunnel.sh` - Completely rewritten with comprehensive fixes
- `scripts/fix-audio-tunnel-complete.sh` - New backup copy
- `scripts/TROUBLESHOOTING.md` - New detailed troubleshooting guide
- `scripts/README.md` - Updated with new script documentation
- `scripts/CHANGELOG-2025-10-16.md` - This file

## Impact

✅ **Audio tunnel restored** to working state
✅ **Automated fix** now available for future issues
✅ **Documentation** created for troubleshooting
✅ **Prevention guidance** added to avoid recurrence

## Timeline

- **10:00 AM** - User reported audio not working
- **10:05 AM** - Initial investigation, found connection refused errors
- **10:15 AM** - Discovered stale SSH processes via `lsof`
- **10:20 AM** - Killed stale processes, restarted socat bridge
- **10:25 AM** - Created fresh tunnel, verified connection
- **10:30 AM** - Audio working, user confirmed success
- **10:40 AM** - Rewrote fix-audio-tunnel.sh script
- **10:50 AM** - Created TROUBLESHOOTING.md documentation
- **11:00 AM** - Updated README.md with new information

## User Feedback

> "its working now, what did u fix?"

User confirmed audio tunnel restored successfully.

## Related Issues

- Previous tunnel outages (not documented)
- X2Go PulseAudio conflicts (documented in guide)
- VS Code Remote SSH tunnel issues (documented in guide)

## References

- [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) - Detailed troubleshooting guide
- [README.md](./README.md) - Scripts documentation
- [Remote Audio Setup Guide](../docs/remote-audio-setup.md) - Original setup guide

---

**Incident resolved:** October 16, 2025
**Resolution time:** ~30 minutes
**Automated fix:** Available via `./scripts/fix-audio-tunnel.sh`
