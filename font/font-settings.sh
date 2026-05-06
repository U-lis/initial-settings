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

  if ! command -v gsettings >/dev/null 2>&1 || ! command -v dconf >/dev/null 2>&1; then
    echo "gsettings/dconf not available. Please set the font manually in your terminal settings."
    return 0
  fi

  if ! gsettings list-schemas 2>/dev/null | grep -q "^org.gnome.Terminal.ProfilesList$"; then
    echo "gnome-terminal schema not found. Please set the font manually in your terminal settings."
    return 0
  fi

  default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
  if [ -z "$default_profile" ]; then
    echo "Could not detect default gnome-terminal profile. Please set the font manually."
    return 0
  fi

  profile_path="/org/gnome/terminal/legacy/profiles:/:$default_profile/"
  dconf write "${profile_path}use-system-font" false
  dconf write "${profile_path}font" "'Inconsolata-dz for Powerline Medium 12'"
  echo "Terminal font change done"
fi
