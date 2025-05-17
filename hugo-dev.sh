    rm -rf public

    hugo serve -D \
        --source blog \
        --contentDir ../content \
        --themesDir ../.themes \
        --destination ../public
