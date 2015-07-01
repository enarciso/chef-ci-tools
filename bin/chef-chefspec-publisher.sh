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

rm junit_reports/chefspec-*.xml 2>/dev/null

PATH=${HOME}/bin:${PATH}
if [ -s ${HOME}/.rvm/scripts/rvm ]
then
    . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
fi

if [ -z `git diff --name-only ${GIT_PREVIOUS_COMMIT} ${GIT_COMMIT} | awk '$1 ~ /^cookbooks/' | awk -F'/' '$3 == "spec"' | awk -F'/' '{print $2}' | uniq` ]; then
    cat > junit_reports/chefspec-dummy.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="rspec" tests="1" failures="0" errors="0" time="0.001334" timestamp="2015-07-01T12:16:36+02:00">
  <!-- Randomized with seed 55589 -->
  <properties/>
  <testcase classname="cookbooks.dummy" name="monitoring f.ing runs" file="" time="0.001192"/>
</testsuite>
EOF

    exit 0
fi

# git submodule cookbooks: git submodule | awk '{print $2}' | awk '$1 ~ /^cookbooks/' | sed -e 's/cookbooks\///'
for cbname in `git diff --name-only ${GIT_PREVIOUS_COMMIT} ${GIT_COMMIT} | awk '$1 ~ /^cookbooks/' | awk -F'/' '$3 == "spec"' | awk -F'/' '{print $2}' | uniq`; do
  `git checkout ${2}`
  echo "------ chefspec checks: $cbname ------"
  rspec cookbooks/${cbname} --format RspecJunitFormatter --out junit_reports/chefspec-${cbname}.xml
done
