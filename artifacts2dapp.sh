#!/bin/bash

node ./scripts/combine_artefacts.js \
    --srcPath $(pwd)/build/contracts \
    --tgtPath=$(pwd)/../edda-dapp/src/config/artifacts_stake.json
