#!/usr/bin/env bash
#===============================================================================
#
#          FILE: nexus-api.sh
#
#         USAGE: ./nexus-api.sh
#
#   DESCRIPTION: Shell CLI for Nexus Sonatype 2.xx API
#
#       OPTIONS: ---
#  REQUIREMENTS: apt-get install -y httpie jq
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Aleksandr Kukhar (kyxap), kyxap@kyxap.pro
#       COMPANY: Fasten.com
#  ORGANIZATION: Operations
#       CREATED: 07/21/2016 23:36
#      REVISION:  ---
#===============================================================================

set -e
set -o nounset                              # Treat unset variables as an error

export LANG=C

### ENVIRONMENT VARIABLES

# required vars
NEXUS_URL="${NEXUS_URL:?}"
NEXUS_USER="${NEXUS_USER:?}"
NEXUS_PASS="${NEXUS_PASS:?}"

# these vars are allowed to be overriden
REPOSITORY="${REPOSITORY:-}"
GROUPID="${GROUPID:-}" ARTIFACTID="${ARTIFACTID:-}" VERSION="${VERSION:-}"
PACKAGING="${PACKAGING:-}"

ROLE=
NODEID=
TYPE=

# common args to httpie
QUERY_AUTH="--auth ${NEXUS_USER}:${NEXUS_PASS}"
QUERY_ARGS="--check-status --body --json --follow --timeout 5"

# nexus rest services
POM_API="/service/local/artifact/maven"
SEARCH_API="/service/local/lucene/search"
CONTENT_API="/service/local/artifact/maven/content"
REDIRECT_API="/service/local/artifact/maven/redirect"
RESOLVE_API="/service/local/artifact/maven/resolve"

# artifacts mapping scheme
MAPPING_PLAIN="services-mapping.plain"
MAPPING_JSON="services-mapping.json"

query() {
  local API="${1:-/nopath}"
  shift

  local HTTPIE_ARGS="${QUERY_AUTH} ${QUERY_ARGS}"

  local QUERY_METHOD="${1:-GET}"
  shift

  local QUERY_URL="${NEXUS_URL}${API}"
  local REQUEST_ITEMS=( "${@:-${REQUEST_ITEMS}}" )
  local CONSTR="${FUNCNAME[1]:-}"

  printf -v HTTPIE -- "${QUERY_METHOD} ${QUERY_URL}"
  printf -v QUERY -- "${HTTPIE_ARGS} ${HTTPIE} ${REQUEST_ITEMS}"
}

### HOST VALIDATOR

validate() {
  local hostname="${@:-}"

  # sample: hostname=order-srv666
  ROLE=${hostname%-*}                          # ROLE=order
  NODEID=${hostname#${hostname/[[:digit:]]*}}  # NODEID=666
  HYPHEN=${hostname#${ROLE}-}                  # HYPHEN=-srv
  TYPE=${HYPHEN%${NODEID}}                     # TYPE=srv

  mapfile -t < services-mapping.plain

  local re="${ROLE}-${TYPE}"

  [[ "${MAPFILE[@]}" =~ $re ]] || { echo Hostname not fround in ${MAPFILE}; return 1; }
}

### CONSTRUCTORS

pom() {
  local REQUEST_ITEMS=( "$@" )
  query "${POM_API}" "GET" "${REQUEST_ITEMS[@]}"
}

search() {
  local REQUEST_ITEMS=( "$@" )
  query "${SEARCH_API}" "GET" "${REQUEST_ITEMS[@]}"
}

content() {
  local REQUEST_ITEMS=( "$@" )
  query "${CONTENT_API}" "GET" "${REQUEST_ITEMS[@]}"
}

redirect() {
  local REQUEST_ITEMS=( "$@" )
  query "${REDIRECT_API}" "GET" "${REQUEST_ITEMS[@]}"
}

resolve() {
  local REQUEST_ITEMS=( "$@" )
  query "${RESOLVE_API}" "GET" "${REQUEST_ITEMS[@]}"
}

