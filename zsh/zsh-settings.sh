DEFAULT_YN='Y'

clear
USER=$(whoami)
echo'Current user is $USER.'
echo'If you want to change default user, type username.'
read -p 'type just RETURN to use $USER as default user' user
user=${user:-$USER}
echo 'DEFAULT_USER='`whoami` >> .zshrc

if [ $1 == 1]; then
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

if [ $2 == 'LINUX' ]; then
	chsh -s /bin/zsh
fi

#cp .zshrc ~/
#source ~/.oh-my-zsh/oh-my-zsh.sh

echo "install Zsh with OMZsh Done."
echo "You have to restart your teminal application to use zsh."
return 1
