#!/usr/bin/env bash
# Usage:
#   ./generate-vscode-settings.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "This program can accept existing VSCode settings directory, in which case it will back up the current settings and generate a new one for you."

PS3="Choose VSCode settings directory [1-3]: "
select choice in "Temporary directory" "./out" "Custom directory"; do
  case "$choice" in
    "Temporary directory")
      OUTPUT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ansible-vscode-out.XXXXXX")"
      break
      ;;
    "./")
      OUTPUT_DIR="./"
      break
      ;;
    "Custom directory")
      read -rp "Enter path: " OUTPUT_DIR
      break
      ;;
  esac
done

PS3="Choose path to nvim.exe [1-3]: "
select choice in "None" "scoop default" "Custom directory"; do
  case "$choice" in
    "None")
      NVIM_EXE=""
      break
      ;;
    "scoop default")
      read -rp "Enter your Windows home directory: C:\\Users\\" USER_NAME
      NVIM_EXE="C:\\Users\\$USER_NAME\\scoop\\shims\\nvim.exe"
      break
      ;;
    "Custom directory")
      read -rp "Enter path: " OUTPUT_DIR
      break
      ;;
  esac
done

mkdir -p "$OUTPUT_DIR"

ansible-playbook \
    --inventory 'localhost,' \
  --connection local \
    --extra-vars "vscode_settings_dir=${OUTPUT_DIR}" \
    --extra-vars "nvim_exe=${NVIM_EXE}" \
    "$SCRIPT_DIR/playbook.yml"

echo "Generated:"
echo "  $OUTPUT_DIR/settings.json"
echo "  $OUTPUT_DIR/keybindings.json"