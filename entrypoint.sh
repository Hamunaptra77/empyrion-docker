#!/bin/bash -e

# === Funktionen ===
timestamp() {
    date +"[%Y-%m-%d %H:%M:%S]"
}

log() {
    echo "$(timestamp) $*"
}

# === Als root: Vorbereitung und Übergabe an user ===
if [ "$UID" = 0 ]; then
    USER_HOME=$(getent passwd user | cut -d: -f6)
    mkdir -p "$USER_HOME/Steam"
    chown -R user: "$USER_HOME/Steam"
    exec runuser -u user -- "$0" "$@"
fi

# === Variablen ===
GAMEDIR="$HOME/Steam/steamapps/common/Empyrion - Dedicated Server/DedicatedServer"
SCENARIO_NAME="${SCENARIO_NAME:-ReforgedEden2}"
SCENARIO_SRC="/scenarios/$SCENARIO_NAME"
SCENARIO_DST="$HOME/Steam/steamapps/common/Empyrion - Dedicated Server/Content/Scenarios/$SCENARIO_NAME"
CONFIG_SRC="/config"
CONFIG_DST="$GAMEDIR"

# === Konfig-Dateien kopieren (nur wenn nicht vorhanden) ===
for cfg in dedicated.yaml adminconfig.yaml config.yaml; do
    if [ ! -f "$CONFIG_DST/$cfg" ] && [ -f "$CONFIG_SRC/$cfg" ]; then
        log "Kopiere Standardkonfiguration: $cfg"
        cp "$CONFIG_SRC/$cfg" "$CONFIG_DST/$cfg"
    fi
done

# === Szenario kopieren ===
if [ ! -d "$SCENARIO_DST" ] && [ -d "$SCENARIO_SRC" ]; then
    log "Installiere benutzerdefiniertes Szenario: $SCENARIO_NAME"
    cp -r "$SCENARIO_SRC" "$(dirname "$SCENARIO_DST")"
fi

# === SteamCMD App-Update ===
cd "$HOME"
STEAMCMD="./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous"
[ -n "$BETA" ] && STEAMCMD="$STEAMCMD -beta experimental"
log "Führe SteamCMD App-Update durch..."
eval "$STEAMCMD +app_update 530870 validate +quit"

# === Xvfb / Wine Setup ===
rm -f /tmp/.X1-lock
Xvfb :1 -screen 0 800x600x24 &
export DISPLAY=:1
export WINEDLLOVERRIDES="mscoree,mshtml="

cd "$GAMEDIR"
mkdir -p Logs

# === Interaktiver Modus? ===
if [ "$1" = "bash" ]; then
    log "Starte interaktive Shell..."
    exec bash
fi

# === Server Watchdog ===
RESTART_COUNT=0
MAX_RESTARTS=100

while true; do
    log "Starte Empyrion Dedicated Server..."
    /opt/wine-staging/bin/wine ./EmpyrionDedicated.exe \
        -batchmode -nographics -logFile Logs/current.log "$@" &> Logs/wine.log

    EXIT_CODE=$?
    ((RESTART_COUNT++))

    log "Serverprozess beendet (Code $EXIT_CODE), Versuch $RESTART_COUNT/$MAX_RESTARTS"

    if [ "$EXIT_CODE" -eq 0 ]; then
        log "Normaler Exit – kein Neustart."
        break
    fi

    if [ "$RESTART_COUNT" -ge "$MAX_RESTARTS" ]; then
        log "Maximale Neustartversuche erreicht. Beende..."
        exit 1
    fi

    log "Warte 10 Sekunden vor Neustart..."
    sleep 10
done
