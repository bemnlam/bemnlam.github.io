#!/bin/zsh
read -p "Create a new post (e.g. hello-world): "  filename

if [ -z "$filename" ]
then

   echo "Filename cannot be empty. Try again."

else

    cd ./blog

    echo ">> 1. Creating new post..."
    hugo new posts/${filename}.md

    echo ">> 2. Launching Typora..."
    open -a Typora ./content/posts/${filename}.md &

    echo ">> 3. Launching browser..."
    open http://localhost:1313/posts/${filename}

    echo ">> 4. Starting dev server..."
    hugo serve -D

fi