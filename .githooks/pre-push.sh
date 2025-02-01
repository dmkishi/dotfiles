#!/usr/bin/env bash
#
# Install: ln -sf pre-push.sh ../.git/hooks/pre-push

set -e

GIT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo '')
if [[ -z "$GIT_TAG" ]]; then
  echo "Git Tag must be set."
  exit 1
fi
