#!/bin/bash

# Set default values
DEFAULT_SELECTION=1
DEFAULT_YN='Y'
SYSTEM=$(uname)

if [ $SYSTEM = 'Linux' ]; then
	SYSTEM_TYPE=$SYSTEM
	INSTALL_COMMAND="sudo apt-get install -y "
elif [ $SYSTEM = 'Darwin' ]; then
	SYSTEM_TYPE='Mac OS X'
	INSTALL_COMMAND="brew -y "
else
	SYSTEM_TYPE='NOT VALID'
fi

# Functions
function has_command() {
	COMMAND="$(which $1)"
	if [ -z "$COMMAND" ]; then
		return 1
	else
		return 0
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
    . ./zsh/zsh-settings.sh $res $SYSTEM "$INSTALL_COMMAND"
    return $?
}

function install_vim() {
    echo "Set .vimrc with vundle/powerline-fonts..."
    has_command vim
    res=$?
    . ./vim/vim-settings.sh $res $SYSTEM "$INSTALL_COMMAND"
}

function install_font() {
    if [ $1 == 2 ]; then
        theme='agnoster'
    fi
    echo "Install powerline-fonts..."
    . ./font/font-settings.sh $SYSTEM $theme
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
				echo "install Homebrew..."
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
            install_git
            install_zsh
            install_vim
            install_font
			read -p 'Press any key to continue...'
			;;
		2 )
            install_git
			read -p 'Press any key to continue...'
			;;
		3 )
            install_zsh
            res=$?
            if [ $res != 0 ]; then
                install_font $res
            fi
			read -p "Press any key to continue..."
			;;
		4 )
            install_vim
            res=$?
            if [ $res != 0 ]; then
                install_font $res
            fi
			read -p "Press any key to continue..."
			;;
		5 )
            install_font
			read -p "Press any key to continue..."
			;;
		* )
			echo "Invalid Input. Please select a number between 0 and 5"
			read -p "Press any key to continue..."
			;;
	esac
done
