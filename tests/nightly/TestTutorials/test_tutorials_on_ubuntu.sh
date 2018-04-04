#!/usr/bin/env bash
cd docs; make html || exit 1
cd ../tests/nightly; export MXNET_HOME=../..; python test_tutorial.py || exit 1; cd ../..;
