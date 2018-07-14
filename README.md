# accu-chek-mobile
For analysis of blood glucose data from an Accu-Chek Mobile.

## Features
1. Each day has its own color to make it easier to differentiate between one day and the next.  
2. If the user correctly marks each blood glucose measurement it will show in the graph, see the sample graph for an example. This makes it easier to spot potential patterns.

![Example graph](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-graph.png)
This example graph was generated with random data.

## Dependencies
Install instructions for docker: https://docs.docker.com/install/

## Instructions
1. Put your csv file in the Inputs directory  
2. Either name it `test.csv` or edit the Snakefile and change the name in the first rule.
3. Run `./start-script`. The docker image will download automatically the first time you run the script.
4. After successful execution the graph is found in the Outputs folder.

## Some comments
At the moment the first snakemake rule is nonsensical since it only copies a file from the Inputs directory to the Outputs directory, it's there because I use it to copy files straight from the Accu-Chek meter.
