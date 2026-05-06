clear

BOLD=$(tput bold)
NORM=$(tput sgr0)
PURPLE='\033[0;35m'
NO_COLOR='\033[0m'
DEFAULT_YN='Y'
DEFAULT_THEME='agnoster'
CUR_USER=$(whoami)

echo "Current user is $CUR_USER."
echo "If you want to change default user, type username."
read -p "type username or just press RETURN to use $CUR_USER as default user : " user
user=${user:-$CUR_USER}

if [ "$1" == 0 ]; then
  echo "You don't have Zsh yet. We will install zsh first."
  read -p "Install Zsh first? If you enter 'n', quit install process. [Y/n] : " input
  input=${input:-$DEFAULT_YN}

  case $input in
  [Yy])
    echo "Install Zsh.."
    $3 zsh zsh-common zsh-doc
    echo "Zsh installed"
    ;;
  [Nn])
    echo "Quit install zsh/omzsh..."
    return 0
    ;;
  esac
fi

ZSH_PATH="$(command -v zsh)"
if [ -z "$ZSH_PATH" ]; then
  echo "zsh is not on PATH after install. Aborting."
  return 1
fi

echo "Install oh-my-zsh..."
RUNZSH=no CHSH=no KEEP_ZSHRC=no \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Change default shell to Zsh ($ZSH_PATH)..."
if ! grep -qx "$ZSH_PATH" /etc/shells; then
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi
chsh -s "$ZSH_PATH"

echo "We will set default theme to $DEFAULT_THEME."
echo "If you choose $DEFAULT_THEME, font will change to 'Inconsolata-dz for Powerline Medium 11'"
read -p "If you want another theme, type theme name or use defualt theme : " theme
theme=${theme:-$DEFAULT_THEME}
mv ~/.zshrc ~/.zshrc.bak
sed -E "s|^ZSH_THEME=.*|ZSH_THEME=\"$theme\"|" ~/.zshrc.bak >~/.zshrc

echo "DEFAULT_USER=$user" >>~/.zshrc

echo "Install Zsh with OMZsh Done."
echo -e "${PURPLE}${BOLD}You have to logout and login to use Zsh.${NORM}${NO_COLOR}"
if [ "$theme" = 'agnoster' ]; then
  return 2
else
  return 1
fi
