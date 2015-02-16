clear

if [ $1 = 'Linux' ]; then
	sudo cp font/*tf /usr/share/fonts/truetype/
	fc-cache
elif [ $1 = 'Darwin' ]; then
	cp font/*tf ~/Library/Fonts
fi

echo "Inconsolata-dz for powerline Installed"
echo "DejaVu Sans Mono for powerline Installed"
if [ -z $2 ]; then
    echo "Please set your terminal's default font to one of them"
    echo "to use your shell in good design"
elif [ $2 != 1 ]; then
    echo "You choose theme $2 so we will set font to Inconsolata-dz for Powerline"
    if [ $1 = 'Linux']; then
        gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_system_font --type bool false
        gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string "Inconsolata-dz for Powerline Medium 11"
    else
        #for mac
    fi
    echo "Terminal font change done"
fi
