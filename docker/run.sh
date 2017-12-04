#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# Builds docker containers using the tag specified in the tool.sh file
# Publishes them if this is triggered from a tagging event and running in the CI

# todo: Do I need these?
HASH=$(git rev-parse HEAD)
TAG=$(basename $(git describe --all --exact-match ${HASH}))
RELEASE_TAG=$(basename $(git tag -l --contains ${HASH}))

# todo: Remove defaults, make env variable
IS_PUBLISH=false
IS_CLEAN=false

echo "HASH: $HASH"
echo "TAG: $TAG"
echo "IS_PUBLISH: $IS_PUBLISH"
echo "RELEASE_TAG: $RELEASE_TAG"


# todo: Add build with gpu_cuda9 here
# todo: Add build with mkl flag here

DEVICES=('cpu' 'gpu')
LANGUAGES=('python' 'julia' 'r-lang' 'scala' 'perl')
for DEV in "${DEVICES[@]}"; do
    for LANG in "${LANGUAGES[@]}"; do
        # Build all docker images
        ./tool.sh build ${LANG} ${DEV} ${HASH}
        ./tool.sh test ${LANG} ${DEV} ${HASH}

        # Push if IS_PUBLISH is set
        if [[ -n "$TAG" && "$IS_PUBLISH" == true ]]; then
            echo "Alert! Pushing to DockerHub"
            ./tool.sh push ${LANG} ${DEV} ${HASH}
        fi

        # Delete the image just built
        if [[ -n "$IS_CLEAN" == true ]]; then
            echo "Deleting the image"
            ./tool.sh clean ${LANG} ${DEV} ${HASH}
        fi
    done
done
