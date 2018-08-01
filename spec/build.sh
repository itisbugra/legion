#!/bin/sh

CYAN="\033[36m"
GREEN="\033[32m"
BOLD="\033[1m"
RESET="\033[0m"

printf "${CYAN}${BOLD} Build started.\n"
printf "${RESET}  1. Cleaning build directory..."
rm -rf _build
printf "${GREEN}${BOLD} [OK]\n${RESET}"

printf "${RESET}  2. Creating new build directory..."
mkdir _build
printf "${GREEN}${BOLD} [OK]\n${RESET}"

printf "${RESET}  3. Resolving cross-references..."
multi-file-swagger ./index.json > ./_build/.middle
multi-file-swagger ./_build/.middle > ./_build/.out
printf "${GREEN}${BOLD} [OK]\n${RESET}"

printf "${RESET}  4. Building static web site..."
bootprint openapi ./_build/.out ./_build > /dev/null
printf "${GREEN}${BOLD} [OK]\n${RESET}"

printf "${GREEN}${BOLD} Build completed.${RESET}\n"

if [ "$1" != "--no-sound" ] && [ "$1" != "-s" ]; then
  printf "\007"
fi
