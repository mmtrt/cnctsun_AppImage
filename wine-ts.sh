#!/bin/sh

progWINE=cnctsun-x.xx-x86_64.AppImage
progBin=game.exe

if command -v "$OWD/$progWINE" > /dev/null 2>&1  ; then
"$OWD/$progWINE" "$progBin" -SPAWN "$*"
fi

if command -v "$HOME/Downloads/$progWINE" > /dev/null 2>&1  ; then
"$HOME/Downloads/$progWINE" "$progBin" -SPAWN "$*"
fi

if command -v "$HOME/$progWINE" > /dev/null 2>&1 ; then
"$HOME/$progWINE" "$progBin" -SPAWN "$*"
fi

if command -v "$HOME/Desktop/$progWINE" > /dev/null 2>&1 ; then
"$HOME/Desktop/$progWINE" "$progBin" -SPAWN "$*"
fi

if command -v "$HOME/bin/$progWINE" > /dev/null 2>&1 ; then
"$HOME/bin/$progWINE" "$progBin" -SPAWN "$*"
fi

if command -v "$HOME/.local/bin/$progWINE" > /dev/null 2>&1 ; then
"$HOME/.local/bin/$progWINE" "$progBin" -SPAWN "$*"
fi
