#!/usr/bin/env bash

function count {
	echo "$1" | wc -l
}

data="$(ls -alR $1 | egrep -v ":$" | egrep -v "^t" | egrep -v "^$")"
data_count=$(count "$data")

dirs="$(echo "$data" | egrep "^d")"

normal_dirs="$(echo "$dirs" | egrep -v "\B\.")"

if [[ "$normal_dirs" = "" ]]
then
	normal_dirs_count=0
else
	normal_dirs_count=$(count "$normal_dirs")
fi

hidden_dirs="$(echo "$dirs" | egrep "\B\.")"

if [[ "$hidden_dirs" = "" ]]
then
	hidden_dirs_count=0
else
	hidden_dirs_count=$(count "$hidden_dirs")
fi

files="$(echo "$data" | egrep -v "^d")"

normal_files="$(echo "$files" | egrep -v "\B\.")"

if [[ "$normal_files" = "" ]]
then
	normal_files_count=0
else
	normal_files_count=$(count "$normal_files")
fi

hidden_files="$(echo "$files" | egrep "\B\.")"

if [[ "$hidden_files" = "" ]]
then
	hidden_files_count=0
else
	hidden_files_count=$(count "$hidden_files")
fi

echo "Files found: $normal_files_count (plus $hidden_files_count hidden)"
echo "Directories found: $normal_dirs_count (plus $hidden_dirs_count hidden)"
echo "Total files and directories: $data_count"
echo

if [[ "$1" != "" ]]
then
	cd "$1"
fi

STRINGS_PER_LINE=9
root=1
root_name="$(pwd)"

function fix_permissions {
	i=1

	if [[ $root -eq 1 ]]
	then
		files="$(ls -al)"
		root=0
	else
		files="$(ls -l)"
	fi

	for string in $(echo "$files" | egrep -v "^t")
	do
		if [[ $i -eq 1 ]]
		then
			permissions=$string
		fi

		if [[ $i -eq $STRINGS_PER_LINE ]]
		then
			file_name=$string

			if [[ $file_name = "." ]]
			then
				file_name="\b"
			fi

			if [[ $file_name != ".." ]]
			then
				echo -e "Permissions for $(pwd)/$file_name $permissions"

				if [[ $permissions = $(echo $permissions | egrep "^d") ]]
				then
					if [[ $permissions != "drwxr-xr-x" ]]
					then
						echo "This directory has the wrong permissions"

						if [[ $file_name = "\b" ]]
						then
							chmod 755 .
						else
							chmod 755 $file_name
						fi

						echo "Permissions changed to drwxr-xr-x"
					fi

					echo

					if [[ $file_name != "\b" ]]
					then
						cd $file_name
						fix_permissions
					fi
				else
					if [[ $permissions != "-rw-r--r--" ]] && [[ $permissions != "-rwxr-xr-x" ]]
					then
						echo "This file has the wrong permissions"

						if [[ $(echo $permissions | grep "x") = "" ]]
						then
							chmod 644 $file_name
							echo "Permissions changed to -rw-r--r--"
						else
							chmod 755 $file_name
							echo "Permissions changed to -rwxr-xr-x"
						fi
					fi

					echo
				fi
			fi

			i=0
		fi

		i=$(expr $i + 1)
	done

	if [[ "$(pwd)" != "root_name" ]]
	then
		cd ..
	fi
}

fix_permissions
