#!/usr/bin/env bash
#===============================================================================
#
#          FILE: nexus-fetch.sh
#
#         USAGE: ./nexus-fetch.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Aleksandr Kukhar (kyxap), kyxap@kyxap.pro
#       COMPANY: Fasten.com
#  ORGANIZATION: Operations
#       CREATED: 07/23/2016 07:33
#      REVISION:  ---
#===============================================================================

set -e
set -o nounset                              # Treat unset variables as an error

ENVIRONMENT=develop
ENVIRONMENT="${ENVIRONMENT:?}"
source "env.${ENVIRONMENT}.list"
source "nexus-api.sh"

# redirect: list coordinates
FILTER='.data[] | select(.artifactHits[].artifactLinks[] .extension == "'${PACKAGING}'" and .version == "'${VERSION:-LATEST}'") | .groupId, .artifactId'

# search: list versions
FILTER='.data[] | select(.artifactHits[].artifactLinks[] .extension ==  "ear" or .extension == "war" and "..| .repositoryId" ) | .version'

httpie() {
  printf -v JQ -- "${@:-%s}" "${FILTER[@]}"
  http ${QUERY} | jq "${JQ[@]:-.}"
}

### MAIN

main() {
  local hostname="${HOSTNAME}"

  validate "$hostname"

  search "r==releases q==${ROLE}"

  httpie "$@"

  redirect "r==releases q==${ROLE}"
}

main "$@"

