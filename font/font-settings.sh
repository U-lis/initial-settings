clear

if [ $1 = 'Linux' ]; then
	sudo cp font/*tf /usr/share/fonts/truetype/
	fc-cache
else
	cp font/*tf ~/Library/Fonts
fi

echo "Inconsolata-dz for powerline Installed"
echo "DejaVu Sans Mono for powerline Installed"
echo "Please set your terminal's default font to one of them"
echo "to use your shell in good design"
