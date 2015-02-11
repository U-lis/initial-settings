clear

DEFAULT_YN="Y"
echo "vimrc setting requires Vundle"
if [ $1 = 1 ]; then
    read -p "You Don't have vim yet. Install vim first? [Y/n] : " input
    input=${input:-$DEFAULT_YN}

    case $input in 
        [Yy] )
            echo "Install vim..."
            $3 vim
            echo "vim installed"
            ;;
        [Nn] )
            echo "Quit vim setting..."
            return 0
            ;;
    esac
fi
echo "Install Vundle..."
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim;
echo "Vundle Installed. Copying .vimrc file..."

if [ ! -f .vimrc ]; then
    echo "vimrc not found. Use sample vimrc to default..."
    cp vim/sample-vimrc ~/.vimrc
else
    echo "vimrc setting..."
    cp .vimrc ~/.vimrc
fi

vim +PluginInstall +qall
echo "vimrc Setting done"
sleep 2
return 1
