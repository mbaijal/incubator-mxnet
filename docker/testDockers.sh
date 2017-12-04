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

#Add tests to check that the image is the one just created - Check the version or the tag
set -e

#1. Python Test
if [[ "${LANGUAGE}" == "python" ]]; then
    echo "Running Python Tests"
    if [[ "${DEVICE}" == "gpu" ]]; then
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/python:gpu bash -c "python tests/python/train/test_conv.py --gpu"
        exit
    fi
    ${DOCKER_BINARY} run --rm -w /mxnet mxnet/python bash -c "python tests/python/train/test_conv.py"
    exit
    fi

#2. r-lang Test
if [[ "${LANGUAGE}" == "r-lang" ]]; then
    echo "Running R-Lang Tests"
    if [[ "${DEVICE}" == *"gpu"* ]]; then
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/r-lang:gpu bash -c "cd R-package/demo/; Rscript basic_model.R --gpu"
        exit
    fi
    ${DOCKER_BINARY} run --rm -w /mxnet mxnet/r-lang bash -c "cd R-package/demo/; Rscript basic_model.R"
    exit
fi

#3. Scala Test
if [[ "${LANGUAGE}" == "scala" ]]; then
    echo "Running Scala Tests"
    if [[ "${DEVICE}" == *"gpu"* ]]; then
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/scala bash -c "cd scala-package/core/; scripts/get_mnist_data.sh; cd /mxnet/; sh scala-package/examples/scripts/module/run_sequential_module.sh --gpu"
        exit
    fi
    ${DOCKER_BINARY} run --rm -w /mxnet mxnet/scala bash -c "cd scala-package/core/; scripts/get_mnist_data.sh; cd /mxnet/; sh scala-package/examples/scripts/module/run_sequential_module.sh"
    exit
fi

#4. Julia Test
if [[ "${LANGUAGE}" == "julia" ]]; then
    echo "Running Julia Tests"
    if [[ "${DEVICE}" == *"gpu"* ]]; then
        # Todo: change this test so we can pass in "gpu" parameter to run on gpu instead
        ${DOCKER_BINARY} run --rm mxnet/julia:gpu bash -c "julia -e 'using MXNet; include(Pkg.dir(\"MXNet\", \"examples\", \"mnist\", \"mlp.jl\"))'"
        exit
    fi
    ${DOCKER_BINARY} run --rm mxnet/julia bash -c "julia -e 'using MXNet; include(Pkg.dir(\"MXNet\", \"examples\", \"mnist\", \"mlp.jl\"))'"
    exit 
fi

#5. Perl Test
if [[ "${LANGUAGE}" == "perl" ]]; then
    echo "Running Perl Tests"
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
