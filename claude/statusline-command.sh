#!/usr/bin/env bash
# Claude Code Status Line Script
# Generates a comprehensive, visually polished status bar with system, git, and session info

input=$(cat)

# ── ANSI color helpers ─────────────────────────────────────────────────────────
# Use $'...' (ANSI-C quoting) so bash stores real ESC bytes, not literal \033.
# This makes the color variables work correctly with printf "%s" and in
# double-quoted strings — no need for printf "%b" or echo -e anywhere.
R=$'\033[0m'          # Reset
BOLD=$'\033[1m'
DIM=$'\033[2m'

# Foreground colors
FG_CYAN=$'\033[36m'
FG_BCYAN=$'\033[96m'   # Bright cyan
FG_BLUE=$'\033[34m'
FG_BBLUE=$'\033[94m'   # Bright blue
FG_MAG=$'\033[35m'
FG_BMAG=$'\033[95m'    # Bright magenta
FG_YEL=$'\033[33m'
FG_BYEL=$'\033[93m'    # Bright yellow
FG_GRN=$'\033[32m'
FG_BGRN=$'\033[92m'    # Bright green
FG_RED=$'\033[31m'
FG_BRED=$'\033[91m'    # Bright red
FG_WHT=$'\033[97m'
FG_GRAY=$'\033[90m'    # Dark gray (dim white)

# Separator character
SEP="${FG_GRAY}│${R}"

# Helper: pick green/yellow/red based on a percentage (higher = worse)
# usage: color_pct <value> <warn_threshold> <crit_threshold>
color_pct() {
    local val="${1:-0}"
    local warn="${2:-50}"
    local crit="${3:-80}"
    if [ "$val" -ge "$crit" ] 2>/dev/null; then
        printf "%s" "$FG_BRED"
    elif [ "$val" -ge "$warn" ] 2>/dev/null; then
        printf "%s" "$FG_BYEL"
    else
        printf "%s" "$FG_BGRN"
    fi
}

# Helper: 5-block mini progress bar  e.g. [████░]
# usage: progress_bar <used_pct>
progress_bar() {
    local pct="${1:-0}"
    local filled=$(( pct * 5 / 100 ))
    local empty=$(( 5 - filled ))
    local bar=""
    local i
    for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
    for (( i=0; i<empty;  i++ )); do bar="${bar}░"; done
    printf "%s" "$bar"
}

# ── Session info from JSON ─────────────────────────────────────────────────────
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
CTX_USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
CTX_REM_PCT=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
TOT_IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOT_OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
CUR_IN=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CUR_OUT=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
CWD=$(echo "$input" | jq -r '.cwd // empty')
TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path // empty')

# ── Identity ───────────────────────────────────────────────────────────────────
USER_NAME=$(whoami 2>/dev/null | sed 's|.*\\||')
HOST_NAME=$(hostname -s 2>/dev/null || hostname 2>/dev/null)

# ── Directory ──────────────────────────────────────────────────────────────────
DIR="${CWD:-$(pwd)}"
HOME_WIN=$(cd ~ && pwd 2>/dev/null)
DIR_DISPLAY="${DIR/#$HOME_WIN/~}"

# ── Git ────────────────────────────────────────────────────────────────────────
GIT_BRANCH=$(git -C "${CWD:-.}" branch --show-current 2>/dev/null)
GIT_CHANGES=$(git -C "${CWD:-.}" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ -n "$GIT_BRANCH" ]; then
    if [ "${GIT_CHANGES:-0}" -gt 0 ]; then
        GIT_DIRTY="${FG_BRED}✗ ${GIT_CHANGES}${R}"
    else
        GIT_DIRTY="${FG_BGRN}✓${R}"
    fi
    GIT_SECTION=" ${SEP} ${FG_BMAG} ${GIT_BRANCH}${R} ${GIT_DIRTY}"
else
    GIT_SECTION=""
fi

# ── System metrics (Windows via PowerShell) ────────────────────────────────────
SYS=$(powershell.exe -NoProfile -NonInteractive -Command "
\$cpu = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
\$os  = Get-WmiObject Win32_OperatingSystem
\$ramUsedMB  = [math]::Round((\$os.TotalVisibleMemorySize - \$os.FreePhysicalMemory) / 1024)
\$ramTotalMB = [math]::Round(\$os.TotalVisibleMemorySize / 1024)
\$ramPct = [math]::Round(\$ramUsedMB / \$ramTotalMB * 100)
Write-Output \"\${cpu}|\${ramUsedMB}|\${ramTotalMB}|\${ramPct}\"
" 2>/dev/null | tr -d '\r')

CPU_PCT=$(echo "$SYS" | cut -d'|' -f1)
RAM_USED=$(echo "$SYS" | cut -d'|' -f2)
RAM_TOTAL=$(echo "$SYS" | cut -d'|' -f3)
RAM_PCT=$(echo "$SYS" | cut -d'|' -f4)

CPU_COLOR=$(color_pct "${CPU_PCT:-0}" 50 80)
RAM_COLOR=$(color_pct "${RAM_PCT:-0}" 50 80)

CPU_SECTION="${CPU_COLOR} ${CPU_PCT:-?}%${R}"
RAM_SECTION="${RAM_COLOR} ${RAM_USED:-?}/${RAM_TOTAL:-?}MB (${RAM_PCT:-?}%)${R}"

# ── Context & tokens ──────────────────────────────────────────────────────────
if [ -n "$CTX_USED_PCT" ]; then
    CTX_COLOR=$(color_pct "${CTX_USED_PCT}" 50 80)
    CTX_BAR=$(progress_bar "${CTX_USED_PCT}")
    CTX_SECTION="${CTX_COLOR} [${CTX_BAR}] ${CTX_USED_PCT}%↑ ${FG_GRAY}/ ${CTX_REM_PCT}%↓${R}"
else
    CTX_SECTION="${FG_GRAY} no msgs yet${R}"
fi

TOT_TOKENS=$((TOT_IN + TOT_OUT))
CUR_TOKENS=$((CUR_IN + CUR_OUT))
TOKEN_SECTION="${FG_WHT} ${TOT_TOKENS}${FG_GRAY} total (last:${CUR_TOKENS})${R}"

# ── Agents (exposed in JSON when applicable) ───────────────────────────────────
AGENT_NAME=$(echo "$input" | jq -r '.agent.name // empty')
if [ -n "$AGENT_NAME" ]; then
    AGENT_SECTION=" ${SEP} ${FG_BCYAN} ${AGENT_NAME}${R}"
else
    AGENT_SECTION=""
fi

# ── Estimated time to completion ───────────────────────────────────────────────
# Strategy:
#   1. Count tool_use blocks in the transcript as a proxy for completed task steps.
#   2. Derive elapsed time from the transcript file's age vs. now.
#   3. Calculate avg seconds per step, then project remaining steps from the
#      fraction of context still unused (remaining % / used % * completed steps).
#   4. Format the estimate as Xh Ym or Ym or "estimating..." when data is thin.
ETA_SECTION=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] && [ -n "$CTX_USED_PCT" ] && [ "$CTX_USED_PCT" -gt 0 ] 2>/dev/null; then
    STEPS_DONE=$(grep -c '"type":"tool_use"' "$TRANSCRIPT" 2>/dev/null || echo 0)
    STEPS_DONE=$((STEPS_DONE + 0))

    if [ "$STEPS_DONE" -gt 1 ]; then
        FILE_MTIME=$(stat -c '%Y' "$TRANSCRIPT" 2>/dev/null || stat -f '%m' "$TRANSCRIPT" 2>/dev/null || echo 0)
        NOW=$(date +%s)
        ELAPSED=$(( NOW - FILE_MTIME ))
        [ "$ELAPSED" -lt 1 ] && ELAPSED=1

        AVG_PER_STEP=$(( ELAPSED / STEPS_DONE ))
        [ "$AVG_PER_STEP" -lt 1 ] && AVG_PER_STEP=1

        CTX_REM_INT=${CTX_REM_PCT%.*}
        CTX_USED_INT=${CTX_USED_PCT%.*}
        [ "${CTX_USED_INT:-0}" -lt 1 ] && CTX_USED_INT=1
        STEPS_REM=$(( STEPS_DONE * CTX_REM_INT / CTX_USED_INT ))

        ETA_SECS=$(( STEPS_REM * AVG_PER_STEP ))

        if [ "$ETA_SECS" -ge 3600 ]; then
            ETA_H=$(( ETA_SECS / 3600 ))
            ETA_M=$(( (ETA_SECS % 3600) / 60 ))
            ETA_STR="${ETA_H}h ${ETA_M}m"
        elif [ "$ETA_SECS" -ge 60 ]; then
            ETA_STR="$(( ETA_SECS / 60 ))m"
        else
            ETA_STR="${ETA_SECS}s"
        fi
        ETA_SECTION=" ${SEP} ${FG_BCYAN}⏱ ~${ETA_STR}${R}"
    else
        ETA_SECTION=" ${SEP} ${DIM}${FG_GRAY}⏱ estimating${R}"
    fi
fi

# ── Assemble the status line ───────────────────────────────────────────────────
printf "${BOLD}${FG_BCYAN} %s${FG_GRAY}@${FG_BGRN}%s${R}  ${BOLD}${FG_BBLUE} %s${R}%s ${SEP} ${BOLD}${FG_BYEL} %s${R} ${SEP} %s ${SEP} %s ${SEP} %s ${SEP} %s%s%s\n" \
    "$USER_NAME" \
    "$HOST_NAME" \
    "$DIR_DISPLAY" \
    "$GIT_SECTION" \
    "$MODEL" \
    "$CTX_SECTION" \
    "$TOKEN_SECTION" \
    "$CPU_SECTION" \
    "$RAM_SECTION" \
    "$AGENT_SECTION" \
    "$ETA_SECTION"
