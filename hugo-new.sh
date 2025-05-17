#!/bin/zsh
COLOR='\033[90;106m' # https://en.wikipedia.org/wiki/ANSI_escape_code
HINT='\033[93;90m'
NC='\033[0m' # No Color

read -p "Create a new buldled post (e.g. hello-world): "  filename

if [ -z "$filename" ]
then

   echo "Filename cannot be empty. Try again."

else
    echo "${COLOR}   1. Creating new post...    ${NC}"
    mkdir content/posts/${filename}
    mkdir content/posts/${filename}/img

    hugo new content \
        --source blog \
        --kind blog \
        --contentDir ../content \
        --themesDir ../.themes \
        posts/${filename}/index.md

    echo "${COLOR}   3. Launching browser...    ${NC}"
    open http://localhost:1313/posts/${filename}

    echo "${COLOR}   1. Launching Obsidian...    ${NC}"
    open -a Obsidian ./content &

    echo "${COLOR}   4. Starting dev server...  ${NC}"
    sh hugo-dev.sh
fi