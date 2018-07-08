#!/bin/bash

docker run --rm -ti -v `pwd`:/data -w /data oskarv/snakemake-bg-tools snakemake -j
