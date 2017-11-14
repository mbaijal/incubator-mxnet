#!/usr/bin/env bash

#Add tests to check that the image is the one just created - Check the version or the tag
    set -e

    #1. Python Test
    if [[ "${LANGUAGE}" == "python" ]]; then
        if [[ "${DEVICE}" == "gpu" ]]; then
            ${DOCKER_BINARY} run --rm -w /mxnet mxnet/python:gpu bash -c "python tests/python/train/test_conv.py --gpu"
            exit
        fi
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/python bash -c "python tests/python/train/test_conv.py"
        exit
    fi

    #2. r-lang Test
    if [[ "${LANGUAGE}" == "r-lang" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            ${DOCKER_BINARY} run --rm -w /mxnet mxnet/r-lang:gpu bash -c "cd R-package/demo/; Rscript basic_model.R --gpu"
            exit
        fi
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/r-lang bash -c "cd R-package/demo/; Rscript basic_model.R"
        exit
    fi

    #3. Scala Test
    if [[ "${LANGUAGE}" == "scala" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            ${DOCKER_BINARY} run --rm -w /mxnet mxnet/scala bash -c "cd scala-package/core/; scripts/get_mnist_data.sh; cd /mxnet/; sh scala-package/examples/scripts/module/run_sequential_module.sh --gpu"
            exit
        fi
        ${DOCKER_BINARY} run --rm -w /mxnet mxnet/scala bash -c "cd scala-package/core/; scripts/get_mnist_data.sh; cd /mxnet/; sh scala-package/examples/scripts/module/run_sequential_module.sh"
        exit
    fi

    #4. Julia Test
    if [[ "${LANGUAGE}" == "julia" ]]; then
        if [[ "${DEVICE}" == *"gpu"* ]]; then
            # TODO: change this test so we can pass in "gpu" parameter to run on gpu instead
            ${DOCKER_BINARY} run --rm mxnet/julia:gpu bash -c "julia -e 'using MXNet; include(Pkg.dir(\"MXNet\", \"examples\", \"mnist\", \"mlp.jl\"))'"
            exit
        fi
        ${DOCKER_BINARY} run --rm mxnet/julia bash -c "julia -e 'using MXNet; include(Pkg.dir(\"MXNet\", \"examples\", \"mnist\", \"mlp.jl\"))'"
        exit
    fi

    #5. Perl Test
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
