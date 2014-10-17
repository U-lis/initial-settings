#!/bin/sh

# Set default values
DEFAULT_SELECTION=1
DEFAULT_YN='Y'
SYSTEM=$(uname)
if [ $SYSTEM = 'Linux' ]; then
	SYSTEM_TYPE=$SYSTEM
	INSTALL_COMMAND="sudo apt-get -y "
elif [ $SYSTEM = 'Darwin' ]; then
	SYSTEM_TYPE='Mac OS X'
	INSTALL_COMMAND="brew -y "
else
	SYSTEM_TYPE='NOT VALID'
fi

# Functions
function has_command() {
	command=`which $1`
	if [ $command != '$1 not found' ]; then
		return 1
	else
		return 0
	fi
}

function setup_zsh() {
	echo "zsh"	
}

function setup_vim() {
	echo "vim"
}

function setup_font() {
	echo "font"
}

# Start from here
clear
echo "This is simple Initial Setting Program"
echo "Your System Type is $SYSTEM_TYPE"

if [ "$SYSTEM_TYPE" = 'NOT VALID' ]; then
	echo "This program does not support current system type $SYSTEM."
	echo "Exting..."
	exit 0
elif [ "$SYSTEM_TYPE" = 'Mac OS X' ]; then
	while true
	do
		echo "We use Homebrew. If not exist, we may install it."
	   	read -p "Install Homebrew? If you disagree, quit this program. type s for skip. [y/s/N] " input
		input=${input:-'N'}
		case $input in
			[Yy] )
				ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
				read -p "Press any key to continue..."
				break
				;;
			[sS] )
				break
				;;
			[Nn] )
				echo "Exiting..."
				exit 0
				;;
			* )
				echo "Invalid input."
				;;
		esac
	done
else
	read -p "Press any key to continue..."
fi

while true
do
	clear
	echo "You can set git alias, .zshrc, .vimrc with appropreate fonts."
	echo "0) Quit"
	echo "1) Set All items [Default]"
	echo "2) Set git alias only"
	echo "3) Set .zshrc with install zsh, oh-my-zsh, powerline-fonts"
	echo "4) Set .vimrc with install Vundle, powerline-fonts"
	echo "5) Install powerline-fonts only"
	read -p  "Input your Choice [All] : " input
	SELECTION=${input:-$DEFAULT_SELECTION}

	case $SELECTION in
		0 )
			echo "Exiting..."
			exit 0 
			;;
		1 )
			echo "Set All Items..."
			setup_git git
			setup_zsh zsh
			setup_vim vim
			setup_font
			sleep 1
			;;
		2 ) 
			echo "Set git alias..."
			has_command git
			echo $?
			. ./git/git-settings.sh $? "$INSTALL_COMMAND"
			read -p 'Press any key to continue...'
			;;
		3 )
			echo "Set .zshrc with zsh/oh-my-zsh/powerline-fonts..."
			setup_zsh zsh
			setup_font
			sleep 1
			;;
		4 ) 
			echo "Set .vimrc with vundle/powerline-fonts..."
			setup_vim vim
			setup_font
			sleep 1
			;;
		5 ) 
			echo "Install powerline-fonts..."
			setup_font
			sleep 1
			;;
		* ) 
			echo "Invalid Input. Please select a number from 0 to 5"
			sleep 0.85
			;;
	esac
done