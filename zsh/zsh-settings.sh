clear

DEFAULT_YN='Y'
DEFAULT_THEME='agnoster'
CUR_USER=$(whoami)
echo "Current user is $CUR_USER."
echo "If you want to change default user, type username."
read -p "type username or just press RETURN to use $CUR_USER as default user : " user
user=${user:-$CUR_USER}

if [ $1 = 1 ]; then
    echo "You don't have Zsh yet. We will install zsh first."
    read -p "Install Zsh first? If you enter 'n', quit install process. [Y/n] : " input
    input=${input:-$DEFAULT_YN}

    case $input in
        [Yy] ) 
            echo "Install Zsh.."
            $3 zsh
            echo "Zsh installed"
            ;;
        [Nn] )
            "Quit install zsh/omzsh..."
            return 0
            ;;
    esac
fi

echo "Install oh-my-zsh..."
wget --no-check-certificate http://install.ohmyz.sh -O - | sh
# curl -L http://install.ohmyz.sh | sh

#if [ $2 = 'LINUX' ]; then
    echo "change default shell to Zsh..."
	chsh -s /bin/zsh
#fi

if [ -f .zshrc ]; then
    echo "We found your .zshrc file. Set rc to this file..."
    cp .zshrc ~/.zshrc
else
    echo ".zshrc file not found. Use Default .zshrc file..."
    echo "We will set defualt theme to $DEFAULT_THEME."
    echo "If you choose $DEFAULT_THEME, font will change to 'Inconsolata-dz for Powerline Medium 11'"
    read -p "If you want another theme, type theme name or use defualt theme" theme
    theme=${theme:-$DEFAULT_THEME}
    mv ~/.zshrc ~/.zshrc.bak
    sed "8s/.*/ZSH_THEME='$theme'/g" ~/.zshrc.bak > ~/.zshrc
fi
source ~/.zshrc

echo "Install Zsh with OMZsh Done."
echo "You have to logout and login to use Zsh."
sleep 2
if [ $theme = 'agnoster' ]; then
    return 2
else
    return 1
