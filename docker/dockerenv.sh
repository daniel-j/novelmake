#!/usr/bin/env bash

set -eo pipefail

cd "${0%/*}"

imagename="djazz/latexenv"

cat ./Dockerfile | docker build --force-rm=true --rm -t "$imagename" -

docker run --rm -it \
	-v "$(realpath ..):/workspace" \
	-v "/etc/passwd:/etc/passwd:ro" \
	-v "/etc/group:/etc/group:ro" \
	--user $(id -u):$(id -g) \
	-e "TERM=$TERM" \
	-e "PS1=[\u@$(tput setaf 6)$(tput bold)\h:$(uname -m)$(tput sgr0) \W]\$ " \
	-h "latexenv" \
	-w /workspace \
	"$imagename" \
	"$@"
