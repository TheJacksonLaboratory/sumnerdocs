#!/bin/bash

## strict check
set -euo pipefail

DOCDIR="$HOME"/Dropbox/acad/scripts/github/webpages/live/sumnerdocs

if [[ ! -d "$DOCDIR" || ! -x "$DOCDIR" ]]; then
	echo -e "\nERROR: DOCDIR does not exists or not accesible at $DOCDIR\n" >&2
	exit 1
fi

## build docs
cd "$DOCDIR" && \
mkdocs build --clean && echo -e "\nINFO: Built updated docs\n" && \
mkdocs gh-deploy --clean -m "published using commit: {sha} and mkdocs {version}"

## END ##
