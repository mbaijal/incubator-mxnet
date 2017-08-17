#!/usr/bin/env bash
# Builds docker containers at the current commit
# Publishes them if this is triggered from a tagging event and running in the CI

HASH=$(git rev-parse HEAD)
TAG=$(basename $(git describe --all --exact-match ${HASH}))

echo "HASH: $HASH"
echo "TAG: $TAG"

DEVICES=('cpu')
LANGUAGES=('python')
for DEV in "${DEVICES[@]}"; do
    for LANG in "${LANGUAGES[@]}"; do
        ./tool.sh build ${LANG} ${DEV} ${HASH}
        ./tool.sh test ${LANG} ${DEV} ${HASH}
        if [[ -n "$TAG" && "$IS_PUBLISH" == true ]]; then
            # Push if triggered by tagging event and IS_PUBLISH is set
            ./tool.sh push ${LANG} ${DEV} ${HASH}
        fi
    done
done
