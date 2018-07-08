FROM oskarv/snakemake
MAINTAINER Oskar Vidarsson <oskar.vidarsson@uib.no>

# Install R
RUN apt-get update && apt-get install -y \
r-base