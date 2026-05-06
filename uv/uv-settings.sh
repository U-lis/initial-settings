clear

BOLD=$(tput bold)
NORM=$(tput sgr0)
PURPLE='\033[0;35m'
NO_COLOR='\033[0m'

echo "Installing uv (https://docs.astral.sh/uv/)..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# Make uv available in the current shell. The installer drops an env file at
# ~/.local/bin/env on recent versions; fall back to extending PATH directly.
if [ -f "$HOME/.local/bin/env" ]; then
  . "$HOME/.local/bin/env"
else
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "uv installation failed. Please check the output above."
  return 1
fi

uv --version

if [ -f "$HOME/.zshrc" ]; then
  ZSH="${ZSH:-$HOME/.oh-my-zsh}"
  if [ -d "$ZSH" ]; then
    echo "Setting up uv shell completion for zsh..."
    mkdir -p "$ZSH/completions"
    uv generate-shell-completion zsh >"$ZSH/completions/_uv"
    uvx generate-shell-completion zsh >"$ZSH/completions/_uvx"
  fi
  echo ""
  echo -e "${PURPLE}${BOLD}Restart your terminal session or run '. ~/.zshrc' to enable uv on PATH${NORM}${NO_COLOR}"
  echo ""
else
  echo "uv installer has appended PATH to ~/.bashrc. Open a new shell to use uv."
fi
