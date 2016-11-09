#!/usr/bin/env bash
# Download this gist
#    curl -Ls https://gist.github.com/andkirby/54204328823febad9d34422427b1937b/raw/semversort.sh | bash
# And run:
#    $ semversort 1.0 1.0-rc 1.0-patch 1.0-alpha
# or in GIT
#    $ semversort $(git tag)
# Using pipeline:
#    $ echo 1.0 1.0-rc 1.0-patch 1.0-alpha | semversort
#
#
# 2016-11-03

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

# Script running with pipeline
if [ -z "${BASH_SOURCE[0]:-}" ]; then
  __dir=/usr/local/bin
  if [ ! -d ${__dir} ]; then
    __dir=/usr/bin
  fi
  __file=${__dir}/semversort
  curl -Ls https://gist.github.com/andkirby/54204328823febad9d34422427b1937b/raw/semversort.sh -o ${__file} && \
    chmod u+x ${__file} && \
    echo 'Semantic version sort: '${__file} && \
    exit 0
  exit 1
fi

if [ -t 0 ]; then
  versions_list=$@
else
  # catch pipeline output
  versions_list=$(cat)
fi

version_weight () {
  echo -e "$1" | tr ' ' "\n"  | sed -e 's:\+.*$::' | sed -e 's:^v::' | \
    sed -re 's:^[0-9]+(\.[0-9]+)+$:&-stable:' | \
    sed -re 's:([^A-z])dev\.?([^A-z]|$):\1.10.\2:g' | \
    sed -re 's:([^A-z])(alpha|a)\.?([^A-z]|$):\1.20.\3:g' | \
    sed -re 's:([^A-z])(beta|b)\.?([^A-z]|$):\1.30.\3:g' | \
    sed -re 's:([^A-z])(rc|RC)\.?([^A-z]|$)?:\1.40.\3:g' | \
    sed -re 's:([^A-z])stable\.?([^A-z]|$):\1.50.\2:g' | \
    sed -re 's:([^A-z])pl\.?([^A-z]|$):\1.60.\2:g' | \
    sed -re 's:([^A-z])(patch|p)\.?([^A-z]|$):\1.70.\3:g' | \
    sed -r 's:\.{2,}:.:' | \
    sed -r 's:\.$::' | \
    sed -r 's:-\.:.:'
}
tags_orig=(${versions_list})
tags_weight=( $(version_weight "${tags_orig[*]}") )

keys=$(for ix in ${!tags_weight[*]}; do
    printf "%s+%s\n" "${tags_weight[${ix}]}" ${ix}
done | sort -V | cut -d+ -f2)

for ix in ${keys}; do
    printf "%s\n" ${tags_orig[${ix}]}
done
