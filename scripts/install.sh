#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="${1:-.}"
SKILLS_DIR="$TARGET_DIR/.claude/skills"
COMMANDS_DIR="$TARGET_DIR/.claude/commands"

mkdir -p "$SKILLS_DIR" "$COMMANDS_DIR"

cp -r "$REPO_ROOT"/.claude/skills/shopify-* "$SKILLS_DIR/"
cp -r "$REPO_ROOT"/.claude/commands/shopify-* "$COMMANDS_DIR/"

echo "Shopify skills → $SKILLS_DIR"
echo "Shopify commands → $COMMANDS_DIR"
