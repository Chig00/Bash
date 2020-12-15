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
