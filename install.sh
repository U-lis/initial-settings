#!/bin/bash

# Set default values
DEFAULT_SELECTION=1
SYSTEM=$(uname)

BOLD=$(tput bold)
NORM=$(tput sgr0)
PURPLE='\033[0;35m'
NO_COLOR='\033[0m'

if [ "$SYSTEM" = 'Linux' ]; then
  SYSTEM_TYPE=$SYSTEM
  INSTALL_COMMAND="sudo apt-get install -y "
#elif [ $SYSTEM = 'Darwin' ]; then
#	SYSTEM_TYPE='Mac OS X'
#	INSTALL_COMMAND="brew -y "
else
  SYSTEM_TYPE='NOT VALID. This script only supports Ubuntu linux.'
fi

# Functions
function wait() {
  read -p "Press any key to continue..."
}

function has_command() {
  COMMAND="$(which "$1")"
  if [ -z "$COMMAND" ]; then
    return 0
  else
    return 1
  fi
}

function install_git() {
  echo "Set git alias..."
  has_command git
  res=$?
  . ./git/git-settings.sh $res "$INSTALL_COMMAND"
}

function install_zsh() {
  echo "Set .zshrc with zsh/oh-my-zsh/powerline-fonts..."
  has_command zsh
  res=$?
  . ./zsh/zsh-settings.sh $res "$SYSTEM" "$INSTALL_COMMAND"
  return $?
}

function install_font() {
  if [ "$1" == 2 ]; then
    theme='agnoster'
  fi
  echo "Install powerline-fonts..."
  . ./font/font-settings.sh "$SYSTEM" $theme
}

function install_poetry() {
  has_command python3
  res=$?

  if [ $res == 0 ]; then
    echo "Poetry needs Python 3.6+. Please install python first."
    return $res
  fi

  python3 --version
  res=$?
  echo $res

  has_command poetry
  res=$?
  . ./poetry/poetry-settings.sh $res
}

# Start from here
clear
echo "This is simple Initial Setting Program"
echo "Your System Type is $SYSTEM_TYPE"

if [ "$SYSTEM_TYPE" = 'NOT VALID' ]; then
  echo "This program does not support current system type $SYSTEM."
  echo "Exiting..."
  exit 0
#elif [ "$SYSTEM_TYPE" = 'Mac OS X' ]; then
#  while true; do
#    echo "We use Homebrew. If not exist, we may install it."
#    read -p "Install Homebrew? If you disagree, quit this program. type s for skip. [y/s/N] " input
#    input=${input:-'N'}
#    case $input in
#    [Yy])
#      echo "install Homebrew..."
#      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#      wait
#      break
#      ;;
#    [sS])
#      break
#      ;;
#    [Nn])
#      echo "Exiting..."
#      exit 0
#      ;;
#    *)
#      echo "Invalid input."
#      ;;
#    esac
#  done
else
  wait
fi

while true; do
  clear
  echo "You can set git alias, .zshrc with appropriate fonts."
  echo "0) Quit"
  echo "1) Set All items [Default]"
  echo "2) Set git alias"
  echo "3) Set .zshrc with install zsh, oh-my-zsh, powerline-fonts"
  echo "4) Install Poetry"
  read -p "Input your Choice [All] : " input
  SELECTION=${input:-$DEFAULT_SELECTION}

  case $SELECTION in
  0)
    echo "Exiting..."
    exit 0
    ;;
  1)
    echo "Set All Items..."
    install_git
    install_zsh
    res=$?
    if [ $res != 0 ]; then
      install_font $res
    fi
    install_poetry
    echo -e "${PURPLE}${BOLD}The script will log you out."
    echo -e "All settings ar done, so you don't need to re run this script.${NORM}${NO_COLOR}"
    wait
    gnome-session-quit --logout --force
    ;;
  2)
    install_git
    wait
    ;;
  3)
    install_zsh
    res=$?
    if [ $res != 0 ]; then
      install_font $res
    fi
    echo -e "${PURPLE}${BOLD}The script will log you out. Please run this script after re-login.${NORM}${NO_COLOR}"
    wait
    gnome-session-quit --logout --force
    ;;
  4)
    install_poetry
    wait
    ;;
  *)
    echo "Invalid Input. Please select a number between 0 and 4"
    wait
    ;;
  esac
done
