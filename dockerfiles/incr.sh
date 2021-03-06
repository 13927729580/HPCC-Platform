#!/bin/bash

##############################################################################
#
#    HPCC SYSTEMS software Copyright (C) 2020 HPCC Systems®.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
##############################################################################

# Use this script to build local images for testing, while leveraging the work already done in the most recent tag
# on the branch that your local branch was based on
#
# Pass in a get commit (that you previously built using this script) if you want to override the default calculation
# of the base build

HEAD=$(git rev-parse --short HEAD)
PREV=$1
# Look for an image that matches a commit, exclude images based on dirty working tree.
[[ -z ${PREV} ]] && PREV=$(git log --format=format:%h-Debug $(git describe --abbrev=0 --tags)..HEAD | grep `docker images hpccsystems/platform-build --format {{.Tag}} | egrep -ve '-dirty$' | head -n 1`)
# If not found above, look for latest tagged
[[ -z ${PREV} ]] && PREV=$(git describe --abbrev=0 --tags)-Debug

# If working tree is dirty, annotate build tag, so doesn't conflict with base commit
[[ -n "$(git status -uno --porcelain)" ]] && DIRTY="-dirty"

BUILD_TYPE=Debug
BUILD_LABEL=${HEAD}-Debug${DIRTY}
BUILD_THREADS=$INPUT_BUILD_THREADS

if [[ "$BUILD_LABEL" == "$PREV" ]] ; then
    echo Docker image hpccsystems/platform-core:${HEAD} already exists
    PREV=$(git log --format=format:%h-Debug $(git describe --abbrev=0 --tags)..HEAD | grep `docker images hpccsystems/platform-build --format {{.Tag}} | head -n 2 | tail -n 1`)
    [[ -z ${PREV} ]] && PREV=$(git describe --abbrev=0 --tags)-Debug
fi
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR 2>&1 > /dev/null

echo Building local incremental images [BUILD_LABEL=${BUILD_LABEL}] based on ${PREV}
    
if [[ -n "$FORCE" ]] ; then
  docker image build -t hpccsystems/platform-build:${BUILD_LABEL} --build-arg PREV_LABEL=${HEAD}-Debug --build-arg BASE_VER=7.8 --build-arg BUILD_TYPE=Debug platform-build/
else
  PREV_COMMIT=$(echo "${PREV}" | sed -e "s/-Debug//")
  git diff --binary ${PREV_COMMIT} ':!./' > platform-build-incremental/hpcc.gitpatch
  # PATCH_MD5 is an ARG of the docker file, which ensures that if different from cached version, image will rebuild from that stage
  PATCH_MD5=$(md5sum platform-build-incremental/hpcc.gitpatch  | awk '{print $1}')
  docker image build -t hpccsystems/platform-build:${BUILD_LABEL} --build-arg PREV_LABEL=${PREV} --build-arg PATCH_MD5=${PATCH_MD5} --build-arg BUILD_THREADS=${BUILD_THREADS} platform-build-incremental/
  rm platform-build-incremental/hpcc.gitpatch
fi
docker image build -t hpccsystems/platform-core:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} platform-core-debug/  

docker image build -t hpccsystems/roxie:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} roxie/  
docker image build -t hpccsystems/dali:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} dali/  
docker image build -t hpccsystems/esp:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} esp/  
docker image build -t hpccsystems/eclccserver:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} eclccserver/  
docker image build -t hpccsystems/eclagent:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} eclagent/  
docker image build -t hpccsystems/hthor:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} hthor/  
docker image build -t hpccsystems/toposerver:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} toposerver/  
docker image build -t hpccsystems/thormaster:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} thormaster/
docker image build -t hpccsystems/thorslave:${BUILD_LABEL} --build-arg BUILD_LABEL=${BUILD_LABEL} thorslave/

echo Built hpccsystems/*:${BUILD_LABEL}

