#!/bin/bash
# Brought to you by the johncena141 release group on 1337x.to
cd "$(dirname "$0")" || exit
echo -e "\e[38;5;$((RANDOM%257))m
   ▄▄        ▄▄
   ██       ███
             ██                                               ▄▄▄          ▄▄▄
 ▀███ ▄████▄ ██████▄▀███████▄  ▄████  ▄▄█▀██▀███████▄  ▄█▀██▄▀███      ▄██▀███
   ████▀  ▀████   ██  ██   ██ ██▀ ██ ▄█▀   ██ ██   ██ ██   ██  ██     ████  ██
   ████    ████   ██  ██   ██ ██     ██▀▀▀▀▀▀ ██   ██  ▄█████  ██   ▄█▀ ██  ██
   ████▄  ▄████   ██  ██   ██ ██▄   ▄██▄    ▄ ██   ██ ██   ██  ██ ▄█▀   ██  ██
   ██ ▀████▀████ ████████ ████▄█████▀ ▀█████▀████ ████▄████▀██████▄████████████▄
██ ██                                                                  ██
▀███         Pain heals. Chicks dig scars. Glory lasts forever!        ██\e[0m"
# Wine settings
export WINEESYNC=1
export WINEFSYNC=1
export WINEARCH=win64
export WINEPREFIX="$PWD/game/prefix"
export WINEDLLOVERRIDES="mscoree=d;mshtml=d;"
export WINE="$PWD/game/proton/files/bin/wine"
export WINE="$(command -v wine)"

# Game files
export EXE="TS3.exe"
export GAME_FOLDER="game/files/The Sims 3/Game/Bin/"

# Extra
CHADTRICKS="$PWD/game/chadtricks.sh"; WINETRICKS="$PWD/winetricks"; SYSWINETRICKS="$(command -v winetricks 2>/dev/null)"; export STAGING_SHARED_MEMORY=1; export WINE_LARGE_ADDRESS_AWARE=1; export WINEDEBUG="fixme-all,warn-all";

# Forbid root rights
[ "$EUID" = "0" ] && exit

# Check for winetricks
[ -n "$SYSWINETRICKS" ] && WINETRICKS=$SYSWINETRICKS && echo "using system winetricks" || echo "using github winetricks"
[ ! -x "$WINETRICKS" ] && curl -L "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" -o winetricks && chmod +x winetricks
[ ! -x "$WINETRICKS" ] && echo -e "\e[91mCould not fetch winetricks and not installed in system\e[0m" && exit 1

# Check for chadtricks
[ ! -x "$CHADTRICKS" ] && curl -L "https://raw.githubusercontent.com/john-cena-141/chadtricks/main/chadtricks.sh" -o game/chadtricks.sh && chmod +x game/chadtricks.sh

# Add dxvk to prefix and auto-update
export DXVK_FRAME_RATE=0; export DXVK_LOG_PATH=none; DXVKVER="$(curl -s https://api.github.com/repos/doitsujin/dxvk/releases/latest | awk -F '["/]' '/"browser_download_url":/ {print $11}' | cut -c 2-)"; SYSDXVK=$(command -v setup_dxvk 2>/dev/null); SYSDXVKVER=$(pacman -Qi dxvk-bin 2>/dev/null | awk -F": " '/Version/ {print $2}' | awk -F"-" '{ print $1 }')
install_dxvk() { [ -n "$SYSDXVK" ] && echo "installing dxvk from system" && $WINE wineboot -i && wineserver -w && $SYSDXVK install && echo "$SYSDXVKVER" > "$PWD/game/prefix/.sysdxvk" && wineserver -k; [ -z "$SYSDXVK" ] && echo "installing dxvk from winetricks" && $WINETRICKS -q dxvk && echo "$DXVKVER" > "$PWD/game/prefix/.dxvk" ; }
[[ ! -f "$PWD/game/prefix/.sysdxvk" && -z "$(awk '/dxvk/ {print $1}' "$WINEPREFIX/winetricks.log" 2>/dev/null)" ]] && install_dxvk || echo "dxvk is installed"
[[ -f "$PWD/game/prefix/.sysdxvk" && "$(cat "$PWD/game/prefix/.sysdxvk")" != "$SYSDXVKVER" ]] && echo "updating dxvk from system" && install_dxvk
[[ -f "$PWD/game/prefix/.dxvk" && -n "$DXVKVER" && "$DXVKVER" != "$(awk '{print $1}' "$PWD/game/prefix/.dxvk")" ]] && echo "newer dxvk version found, installing" && install_dxvk

# winetricks and chadtricks
[[ ! -f "$WINEPREFIX/chadtricks.log" || ! "$(awk '/vcrun2019/ {print $1}' "$WINEPREFIX/chadtricks.log" 2>/dev/null)" ]] && $CHADTRICKS vcrun2019 mf
#[ -z "$(awk '/vcrun2013/ {print $1}' "$WINEPREFIX/winetricks.log" 2>/dev/null)" ] && $WINETRICKS -q vcrun2013

# Start game
cd "$GAME_FOLDER" || exit
gamemoderun "$WINE" "$EXE"
