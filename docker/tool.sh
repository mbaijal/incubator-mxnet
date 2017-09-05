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

#
# Script to build, test and push a docker container
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HASH=$(git rev-parse HEAD)
function show_usage() {
    echo ""
    echo "Usage: $(basename $0) COMMAND LANGUAGE DEVICE HASH"
    echo ""
    echo "   COMMAND: build, test, or push."
    echo "            push needs logined in docker hub"
    echo "   LANGUAGE: the language binding to build, e.g. python, r-lang, julia, scala or perl"
    echo "   DEVICE: targeted device, e.g. cpu, or gpu"
    echo "   COMMIT: hash of the commit to build on"
    echo ""
}

if (( $# < 3 )); then
    show_usage
    exit -1
fi

COMMAND=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
shift 1
LANGUAGE=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
shift 1
DEVICE=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
shift 1
#RELEASE_TAG=$(basename $(git describe --all --exact-match $( echo "$HASH" | tr '[:upper:]' '[:lower:]' )) | sed 's/^v//')
#RELEASE_TAG=${GIT_RELEASE_TAG}
#Only for the release, change back to variable post release. Meghna update to 0.11.0 (correct tag)
#Change Repo to mxnet for release and variable post release
RELEASE_TAG='0.11.0'
DOCKER_REPO='mxnet'
shift 1

DOCKERFILE_LIB="${SCRIPT_DIR}/Dockerfiles/Dockerfile.in.lib.${DEVICE}"
if [ ! -e ${DOCKERFILE_LIB} ]; then
    echo "Error DEVICE=${DEVICE}, failed to find ${DOCKERFILE_LIB}"
    show_usage
    exit 1
fi

DOCKERFILE_LANG="${SCRIPT_DIR}/Dockerfiles/Dockerfile.in.${LANGUAGE}"
if [ ! -e ${DOCKERFILE_LANG} ]; then
    echo "Error LANGUAGE=${LANGUAGE}, failed to find ${DOCKERFILE_LANG}"
    show_usage
    exit 1
fi

# set docker binary
if [[ "${DEVICE}" == *"gpu"* ]] && [[ "{COMMAND}" == "test" ]]; then
    DOCKER_BINARY="nvidia-docker"
else
    DOCKER_BINARY="docker"
fi

# set docker tags
DOCKER_TAG="${DOCKER_REPO}/${LANGUAGE}"
if [[ "${DEVICE}" != 'cpu' ]]; then
    DOCKER_TAG="${DOCKER_TAG}:${DEVICE}"
    if [[ -n "${RELEASE_TAG}" ]]; then
        DOCKER_TAG_VERSIONED="${DOCKER_TAG}_${RELEASE_TAG}"
    fi
elif [[ -n "${RELEASE_TAG}" ]]; then
    DOCKER_TAG_VERSIONED="${DOCKER_TAG}:${RELEASE_TAG}"
fi

# set base dockerfile
DOCKERFILE="Dockerfile.${LANGUAGE}.${DEVICE}"

# print arguments
echo "DOCKER_BINARY: ${DOCKER_BINARY}"
echo "DOCKERFILE: ${DOCKERFILE}"
echo "DOCKER_TAG: ${DOCKER_TAG}"
echo "DOCKER_TAG_VERSIONED: ${DOCKER_TAG_VERSIONED}"

if [[ "${COMMAND}" == "build" ]]; then
    rm -rf ${DOCKERFILE}
    cp ${DOCKERFILE_LIB} ${DOCKERFILE}
    # checkout the release tag
    sed -i "/cd mxnet/ s/$/\n\tgit checkout tags\/${RELEASE_TAG} -b ${RELEASE_TAG} \&\& git submodule update --recursive \&\& \\\/" ${DOCKERFILE}
    cat ${DOCKERFILE_LANG} >>${DOCKERFILE}
    # To remove the following error caused by opencv
    #    libdc1394 error: Failed to initialize libdc1394"
    CMD="sh -c 'ln -s /dev/null /dev/raw1394';"
    # setup scala classpath
    if [[ "${LANGUAGE}" == "scala" ]]; then
        CMD+="CLASSPATH=\${CLASSPATH}:\`ls /mxnet/scala-package/assembly/linux-x86_64-*/target/*.jar | paste -sd \":\"\`"
    fi
    echo "CMD ${CMD} bash" >>${DOCKERFILE}
    ${DOCKER_BINARY} build -t ${DOCKER_TAG} -f ${DOCKERFILE} .
    if [[ -n "${DOCKER_TAG_VERSIONED}" ]]; then
        ${DOCKER_BINARY} tag ${DOCKER_TAG} ${DOCKER_TAG_VERSIONED}
    fi
elif [[ "${COMMAND}" == "test" ]]; then
    set -e
    if [[ "${LANGUAGE}" == "python" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            ${DOCKER_BINARY} run --rm -w /mxnet mxnet/python:gpu bash -c "python tests/python/train/test_conv.py --gpu"
            exit
        fi
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/python bash -c "python tests/python/train/test_conv.py"
        exit
    fi

    if [[ "${LANGUAGE}" == "r-lang" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            ${DOCKER_BINARY} run --rm -w /mxnet mxnet/r-lang:gpu bash -c "cd R-package/demo/; Rscript basic_model.R --gpu"
            exit
        fi
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/r-lang bash -c "cd R-package/demo/; Rscript basic_model.R"
        exit
    fi

    if [[ "${LANGUAGE}" == "scala" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            ${DOCKER_BINARY} run --rm -w /mxnet mxnet/scala bash -c "cd scala-package/core/; scripts/get_mnist_data.sh; cd /mxnet/; sh scala-package/examples/scripts/module/run_sequential_module.sh --gpu"
            exit
        fi
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/scala bash -c "cd scala-package/core/; scripts/get_mnist_data.sh; cd /mxnet/; sh scala-package/examples/scripts/module/run_sequential_module.sh"
        exit
    fi

    if [[ "${LANGUAGE}" == "julia" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            # TODO: change this test so we can pass in "gpu" parameter to run on gpu instead
            ${DOCKER_BINARY} run --rm mxnet/julia:gpu bash -c "julia -e 'using MXNet; include(Pkg.dir(\"MXNet\", \"examples\", \"mnist\", \"mlp.jl\"))'"
            exit
        fi
        ${DOCKER_BINARY} run --rm mxnet/julia bash -c "julia -e 'using MXNet; include(Pkg.dir(\"MXNet\", \"examples\", \"mnist\", \"mlp.jl\"))'"
        exit
    fi

    if [[ "${LANGUAGE}" == "perl" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            ${DOCKER_BINARY} run -w /mxnet --rm mxnet/julia:gpu bash -c "perl perl-package/AI-MXNet/examples/mnist.pl --gpus 0"
            exit
        fi
        ${DOCKER_BINARY} run -w /mxnet --rm mxnet/julia:gpu bash -c "perl perl-package/AI-MXNet/examples/mnist.pl"
        exit
    fi
    set +e

    echo "No tests for language ${LANGUAGE}"
    show_usage
    exit 1
elif [[ "${COMMAND}" == "push" ]]; then
    ${DOCKER_BINARY} push ${DOCKER_TAG}
    if [[ -n "${DOCKER_TAG_VERSIONED}" ]]; then
        ${DOCKER_BINARY} push ${DOCKER_TAG_VERSIONED}
    fi
else
    echo "Unknown COMMAND=${COMMAND}"
    show_usage
    exit 1
fi
