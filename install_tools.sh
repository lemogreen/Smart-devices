#!/bin/bash

echo "Checking envionment..."

# Necessary tools definitions
names=("Homebrew" "Swiftgen" "Swiftlint")
run_cmds=("brew" "swiftgen", "swiftlint")
install_cmds=('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' 'brew install swiftgen' 'brew install swiftlint')

# Checking implementation

ask_and_install() {
	while true; do
	    read -p "$1 is necessary for developing the project. Are you agree to install? (y/n)" yn
	    case $yn in
	        [Yy]* ) eval "$2 2>/dev/null"; break;;
	        [Nn]* ) exit;;
	        * ) echo "Please answer yes or no (y/n).";;
	    esac
	done
}

for i in ${!names[@]};
do
	name=${names[$i]}
	runcmd=${run_cmds[$i]}
	install_cmd=${install_cmds[$i]}

	echo "Checking $name..."

	if hash $runcmd 2>/dev/null; then
		echo "${name} is installed. Skipping."
	else
		ask_and_install "$name" "$install_cmd"
	fi
done

echo "All necessary tools installed"

