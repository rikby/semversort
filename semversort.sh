#!/usr/bin/env bash
# Download
#    curl -Ls https://raw.github.com/rikby/semversort/master/download | bash
# Download particular version
#    curl -Ls https://raw.github.com/rikby/semversort/master/download | bash -s -- --version 0.1.0
# Download and set custom path to binary file
#    curl -Ls https://raw.github.com/rikby/semversort/master/download | bash -s -- --file /usr/local/bin/semverfile
#
# And run:
#    $ semversort 1.0 1.0-rc 1.0-patch 1.0-alpha
# or in GIT
#    $ semversort $(git tag)
# Using pipeline:
#    $ echo 1.0 1.0-rc 1.0-patch 1.0-alpha | semversort
#
# 2016-11-03

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

show_help () {
  cat <<-EOF
Versions sorting 0.2.0
  $ semversort VERSION1 VERSION2 ... VERSION100

Show this help
  $ semversort --help

Sort versions
  $ semversort 1.0 1.0-rc 1.0-patch 1.0-alpha
Sort GIT tags
  $ semversort \$(git tag)
Sort versions Using pipeline:
  $ echo 1.0 1.0-rc 1.0-patch 1.0-alpha | semversort
EOF
}

# Script running with pipeline executing
if [ -z "${BASH_SOURCE[0]:-}" ]; then
  __dir=/usr/local/bin
  if [ ! -d ${__dir} ]; then
    __dir=/usr/bin
  fi

  version=${1:-0.2.0}

  __file=${__dir}/semversort
  curl -Ls https://github.com/rikby/semversort/releases/download/${version}/semversort -o ${__file} && \
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

if [ -z "${versions_list}" ] || [[ "${versions_list:-}" =~ --help ]]; then
  # no versions
  show_help
  exit 0
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
