#!/usr/bin/env bash
# pick an opener in a full-screen fzf list and open the hovered file with it

printf 'Edit\nEdit-Large\nPGP-Encrypt\nExif\nMediaInfo\nReveal\nChmod\nExplain\n' \
    | fzf --height 100% --reverse \
    | xargs -I {} ya emit open --with {}
