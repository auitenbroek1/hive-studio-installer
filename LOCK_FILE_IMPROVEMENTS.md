# Hive Studio Installer - Lock File Handling Improvements

## Problem Solved
Previously, failed installations could leave stale lock files (`~/.hive-studio-installing`) that would block new installations at 14% progress with the error "Another installation is already running!"

Users had to manually discover and delete the lock file to proceed.

## Enhancements Implemented

### 1. **Intelligent Stale Lock Detection**
- Lock files now contain both PID and timestamp: `PID:timestamp`
- Auto-detects locks older than 30 minutes (configurable via `LOCK_TIMEOUT_SECONDS`)
- Automatically removes stale locks from dead processes
- Backward compatible with legacy PID-only lock format

### 2. **Process Validation**
- Checks if the process referenced in the lock file is actually running
- Uses `kill -0 PID` to verify process existence without affecting it
- Differentiates between active processes and dead processes

### 3. **Smart Decision Making**
The system now handles different scenarios intelligently:

| Scenario | Process Running | Lock Age | Action |
|----------|----------------|----------|---------|
| No lock file | N/A | N/A | ✅ Proceed |
| Corrupted lock | N/A | N/A | ✅ Auto-remove and proceed |
| Active process | Yes | < 30min | ❌ Block with helpful message |
| Stuck process | Yes | > 30min | 🤔 Ask user (wait/force/exit) |
| Dead process, old | No | > 30min | ✅ Auto-remove and proceed |
| Dead process, recent | No | < 30min | 🤔 Ask user (cleanup/exit) |

### 4. **Enhanced Error Messages**
- Clear explanations of what's happening
- Specific instructions for manual recovery
- Time information (how long ago the lock was created)
- Process information (PID, running status)

### 5. **Improved Cleanup**
- Enhanced trap handling (`INT TERM EXIT`)
- Lock file cleanup in all error paths
- Cleanup on successful completion
- Cleanup in professional_cleanup() function

### 6. **User-Friendly Recovery**
When manual intervention is needed, users get clear options:

**For stuck processes (running > 30 minutes):**
1. Wait for completion
2. Force-kill and restart
3. Exit and try later

**For orphaned locks (recent but process dead):**
1. Clean up and start fresh (recommended)
2. Exit and investigate manually

## Code Changes Made

### New Functions Added:
- `check_and_handle_lock_file()` - Advanced lock detection and handling
- Enhanced `professional_cleanup()` - Better cleanup with logging

### Modified Functions:
- `validate_system_requirements()` - Now calls advanced lock handling
- Trap handlers - Added EXIT trap for better cleanup
- Lock file format - Now stores `PID:timestamp`

### New Configuration:
- `LOCK_TIMEOUT_SECONDS=1800` (30 minutes timeout)

## Testing
A comprehensive test suite (`test-lock-handling.sh`) validates:
- ✅ No lock file scenario
- ✅ Corrupted lock file handling
- ✅ Stale lock auto-removal
- ✅ Legacy format compatibility
- ✅ Active process blocking

## Benefits

1. **Zero Manual Intervention for Stale Locks**: Most users will never see lock file errors again
2. **Smart Recovery**: Automatically handles common failure scenarios
3. **Safety First**: Still blocks when there's actually an active installation
4. **Clear Communication**: Users understand what's happening and what to do
5. **Backward Compatibility**: Works with existing lock files
6. **Robustness**: Handles edge cases like corrupted lock files

## Usage Examples

### Scenario 1: Stale Lock (Most Common)
```
🔍 Found stale lock file from previous installation
✨ Lock is 45 minutes old and process has exited
✅ Auto-removing stale lock and proceeding...
```

### Scenario 2: Active Installation
```
⚠️ Another installation is currently running (PID: 1234)
✨ Started 5 minutes ago

🧠 Please wait for it to finish, or:
   • Check if it's still active in Activity Monitor
   • If stuck, you can force-quit and run: rm ~/.hive-studio-installing
   • Then restart this installer
```

### Scenario 3: Stuck Process
```
⚠️ Found long-running installation process (PID: 1234, running for 45 minutes)
✨ This might be stuck. What would you like to do?

1. Wait - Let the current installation finish
2. Force - Stop the stuck process and start fresh  
3. Exit - Cancel and try again later
```

This comprehensive solution ensures users have a smooth installation experience without manual lock file management.