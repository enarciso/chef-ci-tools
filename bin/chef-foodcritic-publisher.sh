#!/bin/bash

# Do not fail to parse cookbooks because of the encoding
export LC_CTYPE=en_US.UTF-8

if [ ! -d cookbooks ]; then
    echo 'This script must be run from the root of the chef repository'
    exit 1
fi

if [ ! -d junit_reports ]; then
  mkdir -p junit_reports
fi

rm junit_reports/foodcritic-*.xml 2>/dev/null

PATH=${HOME}/bin:${PATH}
FOODCRITIC=${FOODCRITIC:-foodcritic}
if [ -s ${HOME}/.rvm/scripts/rvm ]
then
    . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi

GIT_PREVIOUS_COMMIT=${1}
GIT_COMMIT=${2}

# Gets the cookbook names from the git diff
for cbname in `git diff --name-only ${GIT_PREVIOUS_COMMIT} ${GIT_COMMIT} | awk '$1 ~ /^cookbooks/' | sed -e 's/cookbooks\///' | awk -F '[/]' '{print $1}' | uniq`; do
  echo "------ foodcritic checks: $cbname ------"
  $FOODCRITIC $@ cookbooks/$cbname | chef-ci-tools/bin/foodcritic2junit.pl --suite $cbname --out junit_reports/foodcritic-$cbname.xml
done
