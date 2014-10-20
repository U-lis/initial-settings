DEFAULT_YN='Y'

clear
USER=`whoami`
echo'Current user is $USER.'
echo'If you want to change default user, type username.'
read -p 'type just RETURN to use $USER as default user' user
user=${user:-$USER}
echo 'DEFAULT_USER='`whoami` >> .zshrc

curl -L github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
# curl -L http://install.ohmyz.sh | sh

if [ $1 = 'LINUX' ]; then
	chsh -s /bin/zsh
fi

cp .zshrc ~/
source ~/.oh-my-zsh/oh-my-zsh.sh

echo "install Zsh with OMZsh Done."
echo "You have to restart your teminal application to use zsh."
