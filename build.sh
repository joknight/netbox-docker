#!/bin/bash

set -e

if [ "${1}x" == "x" ] || [ "${1}" == "--help" ] || [ "${1}" == "-h" ]; then
  echo "Usage: ${0} <branch> [--push]"
  echo "  branch  The branch or tag to build"
  echo "  --push  Push built Docker files to docker hub"
  echo ""
  echo "You can use the following ENV variables to customize the build:"
  echo "  SRC_REPO The Github repository (i.e. github.com/SRC_REPO/netbox) of netbox."
  echo "  DOCKER_REPO The Docker repository (i.e. hub.docker.com/r/DOCKER_REPO/netbox) "
  echo "           Also used for tagging the image."
  echo "  BRANCH   The branch to build."
  echo "           Also used for tagging the image."
  echo "  URL      Where to fetch the package from."
  echo "           Must be a tar.gz file of the source code."

  if [ "${1}x" == "x" ]; then
    exit 1
  else
    exit 0
  fi
fi

SRC_REPO="${SRC_REPO-digitalocean}"
DOCKER_REPO="${DOCKER_REPO-ninech}"
BRANCH="${1}"
URL="${URL-https://github.com/${SRC_REPO}/netbox/archive/$BRANCH.tar.gz}"

if [ "${BRANCH}" == "master" ]; then
  TAG="${TAG-latest}"
elif [ "${BRANCH}" == "develop" ]; then
  TAG="${TAG-snapshot}"
else
  TAG="${TAG-$BRANCH}"
fi

echo "🐳 Building the Docker image '${DOCKER_REPO}/netbox:${TAG}' from the branch '${BRANCH}'."
docker build -f Dockerfile -t "${DOCKER_REPO}/netbox:${TAG}" --build-arg "BRANCH=${BRANCH}" --build-arg "URL=${URL}" --pull .
echo "✅ Finished building the Docker images '${DOCKER_REPO}/netbox:${TAG}'"

if [ "${2}" == "--push" ] ; then
  echo "⏫ Pushing 'netbox:${BRANCH}"
  docker push "${DOCKER_REPO}/netbox:${TAG}"
  echo "✅ Finished pushing the Docker images."
fi