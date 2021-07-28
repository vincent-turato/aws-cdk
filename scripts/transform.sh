#!/bin/bash

set -euo pipefail
scriptdir=$(cd $(dirname $0) && pwd)

runtarget="build"
run_tests="true"
extract_snippets="false"
skip_build=""
while [[ "${1:-}" != "" ]]; do
    case $1 in
        -h|--help)
            echo "Usage: transform.sh [--skip-test/build] [--extract]"
            exit 1
            ;;
        --skip-test|--skip-tests)
            run_tests="false"
            ;;
        --skip-build)
            skip_build="true"
            ;;
        --extract)
            extract_snippets="true"
            ;;
        *)
            echo "Unrecognized options: $1"
            exit 1
            ;;
    esac
    shift
done
if [ "$run_tests" == "true" ]; then
    runtarget="$runtarget+test"
fi
if [ "$extract_snippets" == "true" ]; then
    runtarget="$runtarget+extract"
fi

export NODE_OPTIONS="--max-old-space-size=4096 --experimental-worker ${NODE_OPTIONS:-}"

# copy & build the packages that are individually released from 'aws-cdk-lib'
cd ${scriptdir}/../packages/individual-packages
node ../../tools/individual-packages-gen/gen-phase1.js
yarn lerna bootstrap
node ../../tools/individual-packages-gen/gen-phase2.js
if [ "$skip_build" != "true" ]; then
  PHASE=transform yarn lerna run --stream $runtarget
fi
