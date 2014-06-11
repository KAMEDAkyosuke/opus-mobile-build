#!/bin/sh -x

set -e

source ./setting.sh

# add opus
git submodule add git://git.opus-codec.org/opus.git opus
cd opus
git checkout $OPUS_TAG

