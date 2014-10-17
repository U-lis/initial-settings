DEFAULT_YN='Y'

clear
if [ $1 = 1 ]; then
	read -p "You don't have git yet. Proceed with install git? [Y/n] : " input
	input=${input:-$DEFAULT_YN}

	case $input in
		[Yy] )
			echo "install Git..."
			$2 git
			echo "git installed"
			;;
		[Nn] )
			echo "Exit setting up git..."
	esac
fi

echo "setting git alias..."
git config --global --replace-all alias.co 'checkout'
echo "Now, git co master == git checkout master"
git config --global --replace-all alias.st 'status -sb'
echo "Now, git st == git status -sb"
git config --global --replace-all alias.tags 'tag -l'
echo "Now, git tags == git tag -l"
git config --global --replace-all alias.br 'branch -a'
echo "Now, git br == git branch -a"
git config --global --replace-all alias.re 'remote -v'
echo "Now, git re == git remote -v"
git config --global --replace-all alias.lg "log --color --graph \
	--pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' \
	--abbrev-commit --"
echo "Now, git lg == git log (with pretty format)"
echo "Setting Complete!!"
