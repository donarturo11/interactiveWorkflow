#!/usr/bin/env bash

BREW_PREFIX=$(brew --prefix || echo ".homebrew")

if [ "$(uname)" = "Darwin" ]; then
echo "Cache location $(brew --cache)"
BREW_BIN_PATH=""
ls $PREFIX
else
BREW_BIN_PATH=${BREW_PREFIX}/bin/
echo "This system is not MacOS"
fi

mkdir -p ~/brew-cache/{arm64,x86_64}
mkdir -p ~/brew-mod/{arm64,x86_64}

HOMEBREW_CACHE=~/brew-cache/arm64 ${BREW_BIN_PATH}brew fetch -q --force --bottle-tag=arm64_monterey --deps qt@6
HOMEBREW_CACHE=~/brew-cache/x86_64 ${BREW_BIN_PATH}brew fetch -q --force --bottle-tag=monterey --deps qt@6

for i in ~/brew-cache/arm64/downloads/*
do 
  echo "Preparing ${i} for ARM"
  tar -xzf "$i" -C ~/brew-mod/arm64
  rm "$i"
done
for i in ~/brew-cache/x86_64/downloads/*
do 
  echo "Preparing ${i} for x86_64"
  tar -xzf "$i" -C ~/brew-mod/x86_64
  rm "$i"
done



