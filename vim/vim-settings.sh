echo "vimrc setting requires Vundle"
echo "Install Vundle..."
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim;
echo "Vundle Installed. Copying .vimrc file..."
cp .vimrc ~/
vim +PluginInstall +qall
echo "You may have to install font for powerline"
