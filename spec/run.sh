#!/bin/sh

GREEN="\033[32m"
CYAN="\033[35m"
BOLD="\033[1m"
RESET="\033[0m"

if [ "$1" == "--help" ]; then
  printf "usage:\n"
  printf "\t./run.sh [...options]\n"
  printf "args:"
  printf " --no-sound\t-s\tDisables terminal bell on post-build.\n"
  printf " --help\t-h\tPrints this information.\n"
else
  printf "${CYAN}${BOLD} Starting HTTP server...\n${RESET}"
  mkdir _build > /dev/null 2>&1
  http-server _build | sed -n 2,4p &
  sleep 2
  rm -r _build

  printf "${CYAN}${BOLD} Instantiating first build...\n${RESET}"
  ./build.sh

  printf "${GREEN}${BOLD} Runloop started, waiting for a file change.${RESET}\n"
  fswatch -e ".*" -i ".*[^_]*\\.json$" . | xargs -n1 $PWD/build.sh
fi
