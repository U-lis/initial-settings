clear

if [ $1 == 'Linux' ]; then
	sudo cp *tf /usr/share/fonts/trutype/
	fc-cache
else
	cp *tf ~/Library/Fonts
fi

echo "Inconsolata-dz for powerline Installed"
echo "DejaVu Sans Mono for powerline Installed"
echo "Please set your terminal's default font to one of them"
echo "to use your shell in good design"
