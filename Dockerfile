FROM oskarv/snakemake
MAINTAINER Oskar Vidarsson <oskar.vidarsson@uib.no>

# Install R
RUN apt-get update && apt-get install -y \
r-base

RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('lubridate')"