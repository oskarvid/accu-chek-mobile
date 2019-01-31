#!/bin/bash

docker run --rm -ti -u $UID:1000 -v `pwd`:/data -w /data oskarv/snakemake-bg-tools snakemake -j
