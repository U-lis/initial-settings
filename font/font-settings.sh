clear

sudo cp font/*tf /usr/share/fonts/truetype/
fc-cache

echo "Inconsolata-dz for powerline Installed"
echo "DejaVu Sans Mono for powerline Installed"
if [ -z "$2" ]; then
  echo "Please set your terminal's default font to one of them"
  echo "to use your shell in good design"
elif [ "$2" != 1 ]; then
  echo "You choose theme $2 so we will set font to Inconsolata-dz for Powerline"
  shell_version="$(gnome-shell --version)"
  IFS=' '
  arr=("$shell_version")
  IFS='.'
  ver=("${arr[2]}")
  minor_version=${ver[1]}
  if [ "$minor_version" -lt "8" ]; then
    gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_system_font --type bool false
    gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string "Inconsolata-dz for Powerline Medium 12"
  else
    default_profile="b1dcc9dd-5262-4d8d-a863-c897e6d979b9"
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/use-system-font "false"
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/font "'Inconsolata-dz for Powerline Medium 12'"
  fi
  echo "Terminal font change done"
fi
