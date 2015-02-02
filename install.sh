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
			. ./git/git-settings.sh $? "$INSTALL_COMMAND"
			. ./zsh/zsh-settings.sh $SYSTEM
			setup_vim vim
			. ./font/font-settings.sh $SYSTEM
			read -p 'Press any key to continue...'
			;;
		2 )
			echo "Set git alias..."
			has_command git
			echo $?	# ehco를 해주지 않으면 값이 제대로 전달되지 않는다.
			. ./git/git-settings.sh $? "$INSTALL_COMMAND"
			read -p 'Press any key to continue...'
			;;
		3 )
			echo "Set .zshrc with zsh/oh-my-zsh/powerline-fonts..."
            has_command zsh
			. ./zsh/zsh-settings.sh $? $SYSTEM "$INSTALL_COMMAND"
            if [ $? == '1' ]; then
                . ./font/font-settings.sh $SYSTEM
            fi
			read -p 'Press any key to continue...'
			;;
		4 )
			echo "Set .vimrc with vundle/powerline-fonts..."
			setup_vim vim
			. ./font/font-settings.sh $SYSTEM
			read -p 'Press any key to continue...'
			;;
		5 )
			echo "Install powerline-fonts..."
			. .font/font.sh $SYSTEM
			read -p 'Press any key to continue...'
			;;
		* )
			echo "Invalid Input. Please select a number from 0 to 5"
			read -p 'Press any key to continue...'
			;;
	esac
done
