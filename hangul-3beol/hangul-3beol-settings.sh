# Sourced from install.sh.
# Args:
#   $1 = INSTALL_COMMAND (e.g. "sudo apt-get install -y ")
#
# Installs 3beol forks of libhangul and ibus-hangul to enable
# 세모이(Sebeolsik Semoe) keyboards with 한 번에 모아치기 input mode.
#
# Repos verified at:
#   https://gitlab.com/3beol/libhangul
#   https://gitlab.com/3beol/ibus-hangul
#
# Final layout:
#   /usr/local/lib/libhangul.so.1.*           (apt's libhangul1 left untouched)
#   /usr/libexec/ibus-engine-hangul           (overwrites apt ibus-hangul)
#   /usr/share/ibus-hangul/setup/*            (overwrites apt ibus-hangul)
# Revert: sudo apt install --reinstall ibus-hangul; sudo make uninstall in libhangul repo.

clear

BOLD=$(tput bold)
NORM=$(tput sgr0)
PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

DEFAULT_YN='Y'
INSTALL_COMMAND="${1:-sudo apt-get install -y }"
WORK_DIR="${HANGUL_WORK_DIR:-$HOME/Downloads}"
LIBHANGUL_DIR="$WORK_DIR/libhangul-3beol"
IBUS_HANGUL_DIR="$WORK_DIR/ibus-hangul-3beol"

echo "Set up 3beol forks of libhangul + ibus-hangul (세모이 자판 / 한 번에 모아치기)."
echo ""
echo "Repos cloned to     : $WORK_DIR"
echo "libhangul prefix    : /usr/local"
echo "ibus-hangul prefix  : /usr (overwrites apt's ibus-hangul package files)"
echo ""
read -p "Proceed? [Y/n] : " input
input=${input:-$DEFAULT_YN}
case $input in
[Nn])
  echo "Skipping hangul setup."
  return 0
  ;;
esac

# Cache sudo upfront so the rest of the script doesn't re-prompt mid-build.
sudo -v || {
  echo -e "${RED}sudo required.${NO_COLOR}"
  return 1
}

echo ""
echo -e "${PURPLE}${BOLD}[1/6] Installing build dependencies via apt...${NORM}${NO_COLOR}"
$INSTALL_COMMAND \
  build-essential autoconf automake libtool intltool autopoint \
  pkg-config gettext git \
  libexpat1-dev libibus-1.0-dev libgtk-3-dev || {
  echo -e "${RED}Failed to install build dependencies.${NO_COLOR}"
  return 1
}

mkdir -p "$WORK_DIR"

echo ""
echo -e "${PURPLE}${BOLD}[2/6] Cloning libhangul (3beol fork)...${NORM}${NO_COLOR}"
if [ -d "$LIBHANGUL_DIR/.git" ]; then
  echo "Already cloned at $LIBHANGUL_DIR. Pulling latest..."
  git -C "$LIBHANGUL_DIR" pull --ff-only || true
else
  git clone https://gitlab.com/3beol/libhangul "$LIBHANGUL_DIR" || {
    echo -e "${RED}Failed to clone libhangul.${NO_COLOR}"
    return 1
  }
fi

echo ""
echo -e "${PURPLE}${BOLD}[3/6] Building and installing libhangul to /usr/local...${NORM}${NO_COLOR}"
(
  set -e
  cd "$LIBHANGUL_DIR"
  ./autogen.sh
  ./configure
  make -j"$(nproc)"
  sudo make install
  sudo ldconfig
) || {
  echo -e "${RED}Failed to build/install libhangul.${NO_COLOR}"
  return 1
}

echo ""
echo -e "${PURPLE}${BOLD}[4/6] Cloning ibus-hangul (3beol fork)...${NORM}${NO_COLOR}"
if [ -d "$IBUS_HANGUL_DIR/.git" ]; then
  echo "Already cloned at $IBUS_HANGUL_DIR. Pulling latest..."
  git -C "$IBUS_HANGUL_DIR" pull --ff-only || true
else
  git clone https://gitlab.com/3beol/ibus-hangul "$IBUS_HANGUL_DIR" || {
    echo -e "${RED}Failed to clone ibus-hangul.${NO_COLOR}"
    return 1
  }
fi

echo ""
echo -e "${PURPLE}${BOLD}[5/6] Building and installing ibus-hangul to /usr...${NORM}${NO_COLOR}"
(
  set -e
  cd "$IBUS_HANGUL_DIR"
  NOCONFIGURE=1 ./autogen.sh
  ./configure --prefix=/usr --libexecdir=/usr/libexec
  make -j"$(nproc)"
  sudo make install
) || {
  echo -e "${RED}Failed to build/install ibus-hangul.${NO_COLOR}"
  return 1
}

echo ""
read -p "Hold ibus-hangul package to prevent apt upgrade overwriting it? [Y/n] : " input
input=${input:-$DEFAULT_YN}
case $input in
[Yy])
  sudo apt-mark hold ibus-hangul
  ;;
esac

echo ""
echo -e "${PURPLE}${BOLD}[6/6] Configuring ibus-hangul gsettings...${NORM}${NO_COLOR}"
# Required: with use-event-forwarding=true (the schema default), space and
# backspace are silently dropped on ibus 1.5.34-rc2 + 3beol ibus-hangul 1.5.4.
gsettings set org.freedesktop.ibus.engine.hangul use-event-forwarding false
echo "  use-event-forwarding = false  (fixes space/backspace)"

read -p "Set default Hangul keyboard to 'Sebeolsik Semoe 2018'? [Y/n] : " input
input=${input:-$DEFAULT_YN}
case $input in
[Yy])
  gsettings set org.freedesktop.ibus.engine.hangul hangul-keyboard '3moa-semoe-2018'
  echo "  hangul-keyboard = 3moa-semoe-2018"
  ;;
esac

echo ""
echo -e "${PURPLE}${BOLD}Restarting ibus daemon...${NORM}${NO_COLOR}"
ibus restart 2>/dev/null || (ibus exit 2>/dev/null; sleep 1; ibus-daemon -drx >/dev/null 2>&1 &)

echo ""
echo -e "${GREEN}${BOLD}Hangul (3beol fork) setup complete.${NORM}${NO_COLOR}"
echo ""
echo "Verify with:"
echo "  ldd /usr/libexec/ibus-engine-hangul | grep hangul"
echo "    -> should resolve to /usr/local/lib/libhangul.so.1"
echo "  ibus-setup-hangul    # open setup UI to pick keyboard / view layouts"
echo ""
echo "If keyboard switcher does not show 세모이 in your input source list,"
echo "log out and back in, or reboot."
