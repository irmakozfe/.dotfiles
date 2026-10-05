#!/usr/bin/env bash
# convert-all --epub <target_folder> <output_folder>


[[ $# -eq 3 ]] || usage
[[ $1 == --* ]] || usage 

usage(){
	echo "Format: convert-all --epub <target_folder> <output_folder>"
	exit 1
}


format="${1#--}"
target="$2"
output="$3"

command -v ebook-convert > /dev/null || {
	echo "ebook-convert needed. Install it before you run the script."
	exit 1
}

[[ -d $target ]] || { echo "'$target' not found."; exit 1; }

mkdir -p "$output"

for file in "$target"/*.pdf; do

	if [ !  -e "$file" ]; then
		echo "No pdf files found."
		exit 0 
	fi

	name=$(basename "$file" .pdf)
	
	echo "converting: $name.pdf"
	ebook-convert "$file" "$output/$name.$format" > /dev/null
done

echo "Done. Files are in $output"
