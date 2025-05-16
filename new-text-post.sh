#!/bin/zsh
COLOR='\033[90;106m' # https://en.wikipedia.org/wiki/ANSI_escape_code
HINT='\033[93;90m'
NC='\033[0m' # No Color

read -p "Create a new post (e.g. hello-world): "  filename

if [ -z "$filename" ]
then

   echo "Filename cannot be empty. Try again."

else

    cd ./blog

    echo "${COLOR}   1. Creating new post...    ${NC}"
    hugo new posts/${filename}.md

    echo "${COLOR}   2. Launching Typora...     ${NC}"
    open -a Typora ./content/posts/${filename}.md &

    echo "${COLOR}   3. Launching browser...    ${NC}"
    open http://localhost:1313/posts/${filename}

    echo "${COLOR}   4. Starting dev server...  ${NC}"
    hugo serve -D

fi