#!/bin/bash

set -e

if [ "${1}x" == "x" ] || [ "${1}" == "--help" ] || [ "${1}" == "-h" ]; then
  echo "Usage: ${0} <branch> [--push]"
  echo "  branch  The branch or tag to build. Required."
  echo "  --push  Pushes built Docker image to docker hub."
  echo ""
  echo "You can use the following ENV variables to customize the build:"
  echo "  DOCKER_OPTS Add parameters to Docker."
  echo "           Default:"
  echo "             When <TAG> starts with 'v':  \"\""
  echo "             Else:                        \"--no-cache\""
  echo "  BRANCH   The branch to build."
  echo "           Also used for tagging the image."
  echo "  TAG      The version part of the docker tag."
  echo "           Default:"
  echo "             When <BRANCH>=master:  latest"
  echo "             When <BRANCH>=develop: snapshot"
  echo "             Else:          same as <BRANCH>"
  echo "  DOCKER_ORG The Docker registry (i.e. hub.docker.com/r/<DOCKER_ORG>/<DOCKER_REPO>) "
  echo "           Also used for tagging the image."
  echo "           Default: ninech"
  echo "  DOCKER_REPO The Docker registry (i.e. hub.docker.com/r/<DOCKER_ORG>/<DOCKER_REPO>) "
  echo "           Also used for tagging the image."
  echo "           Default: netbox"
  echo "  DOCKER_TAG The name of the tag which is applied to the image."
  echo "           Useful for pushing into another registry than hub.docker.com."
  echo "           Default: <DOCKER_ORG>/<DOCKER_REPO>:<BRANCH>"
  echo "  SRC_ORG  Which fork of netbox to use (i.e. github.com/<SRC_ORG>/<SRC_REPO>)."
  echo "           Default: digitalocean"
  echo "  SRC_REPO The name of the netbox for to use (i.e. github.com/<SRC_ORG>/<SRC_REPO>)."
  echo "           Default: netbox"
  echo "  URL      Where to fetch the package from."
  echo "           Must be a tar.gz file of the source code."
  echo "           Default: https://github.com/<SRC_ORG>/<SRC_REPO>/archive/\$BRANCH.tar.gz"

  if [ "${1}x" == "x" ]; then
    exit 1
  else
    exit 0
  fi
fi

# variables for fetching the source
SRC_ORG="${SRC_ORG-digitalocean}"
SRC_REPO="${SRC_REPO-netbox}"
BRANCH="${1}"
URL="${URL-https://github.com/${SRC_ORG}/${SRC_REPO}/archive/$BRANCH.tar.gz}"

# variables for tagging the docker image
DOCKER_ORG="${DOCKER_ORG-ninech}"
DOCKER_REPO="${DOCKER_REPO-netbox}"
case "${BRANCH}" in
  master)
    TAG="${TAG-latest}";;
  develop)
    TAG="${TAG-snapshot}";;
  *)
    TAG="${TAG-$BRANCH}";;
esac
DOCKER_TAG="${DOCKER_TAG-${DOCKER_ORG}/${DOCKER_REPO}:${TAG}}"

# caching is only ok for version tags
case "${TAG}" in
  v*)
    CACHE="${CACHE-}";;
  *)
    CACHE="${CACHE---no-cache}";;
esac

# Docker options
DOCKER_OPTS="${DOCKER_OPTS-$CACHE}"

echo "🐳 Building the Docker image '${DOCKER_TAG}' from the url '${URL}'."
docker build -t "${DOCKER_TAG}" --build-arg "BRANCH=${BRANCH}" --build-arg "URL=${URL}" --pull ${DOCKER_OPTS} .
echo "✅ Finished building the Docker images '${DOCKER_TAG}'"

if [ "${2}" == "--push" ] ; then
  echo "⏫ Pushing '${DOCKER_TAG}"
  docker push "${DOCKER_TAG}"
  echo "✅ Finished pushing the Docker image '${DOCKER_TAG}'."
fi
