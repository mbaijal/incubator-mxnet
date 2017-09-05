#!/usr/bin/env bash
# Builds docker containers at the current commit
# Publishes them if this is triggered from a tagging event and running in the CI

HASH=$(git rev-parse HEAD)
TAG=$(basename $(git describe --all --exact-match ${HASH}))
RELEASE_TAG=$(basename $(git tag -l --contains ${HASH}))
#only for release, meghna, update back to variable
IS_PUBLISH=false

echo "HASH: $HASH"
echo "TAG: $TAG"
echo "IS_PUBLISH: $IS_PUBLISH"
echo "RELEASE_TAG: $RELEASE_TAG"


DEVICES=('cpu' 'gpu')
LANGUAGES=('python' 'julia' 'r-lang' 'scala' 'perl')
for DEV in "${DEVICES[@]}"; do
    for LANG in "${LANGUAGES[@]}"; do
        ./tool.sh build ${LANG} ${DEV} ${HASH}
        ./tool.sh test ${LANG} ${DEV} ${HASH}
        if [[ -n "$TAG" && "$IS_PUBLISH" == true ]]; then
            # Push if triggered by tagging event and IS_PUBLISH is set
            echo "Alert! Pushing to DockerHub, using account mbaijal!"
            ./tool.sh push ${LANG} ${DEV} ${HASH}
        fi
    done
done
