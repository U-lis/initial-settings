clear

BOLD=$(tput bold)
NORM=$(tput sgr0)
PURPLE='\033[0;35m'
NO_COLOR='\033[0m'

echo "Installing poetry..."
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 -

echo "To use poetry without error, python3-distutils package needed"
sudo apt install -y python3-distutils

echo "Set alias pt to poetry..."
cmd=(alias pt="poetry")
if [ -f "$HOME/.zshrc" ]; then
  ZSH=/home/$(whoami)/.oh-my-zsh
  echo "${cmd[@]}" >>"$HOME/.zshrc"
  #  . "$HOME/.zshrc"
  echo "Setting up poetry plugin for zsh..."
  mkdir "$ZSH"/plugins/poetry
  poetry completions zsh >"$ZSH"/plugins/poetry/_poetry
  mv ~/.zshrc ~/.zshrc.bak
  sed "73s/.*/plugins=(git poetry)/g" ~/.zshrc.bak >~/.zshrc
  echo ""
  echo -e "${PURPLE}${BOLD}You have to restart terminal session or run '. ~/.zshrc' to apply alias${NORM}${NO_COLOR}"
  echo ""
else
  echo "${cmd[@]}" >>"$HOME/.bashrc"
  . "$HOME/.bashrc"
fi
