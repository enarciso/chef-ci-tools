#!/bin/bash -x

# Do not fail to parse cookbooks because of the encoding
export LC_CTYPE=en_US.UTF-8

if [ ! -d cookbooks ]; then
    echo 'This script must be run from the root of the chef repository'
    exit 1
fi

if [ ! -d junit_reports ]; then
  mkdir -p junit_reports
fi

PATH=${HOME}/bin:${PATH}
#RSPEC=${RSPEC:-rspec} # figure this out
if [ -s ${HOME}/.rvm/scripts/rvm ]
then
    . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi

# git submodule cookbooks: git submodule | awk '{print $2}' | awk '$1 ~ /^cookbooks/' | sed -e 's/cookbooks\///'
for cbname in `git diff --name-only ${GIT_PREVIOUS_COMMIT} ${GIT_COMMIT} | awk '$1 ~ /^cookbooks/' | awk -F'/' '$3 == "spec"' | awk -F'/' '{print $2}' | uniq`; do
  rm junit_reports/chefspec-${cbname}.xml 2>/dev/null
  echo "------ chefspec checks: $cbname ------"
  rspec $@ cookbooks/${cbname} --format RspecJunitFormatter --out junit_reports/chefspec-${cbname}.xml
done
