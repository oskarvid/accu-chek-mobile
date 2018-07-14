# accu-chek-mobile
For analysis of blood glucose data from an Accu-Chek Mobile.

![Example graph](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-graph.png)
This graph was generated with random data.

## Dependencies
Docker: https://docs.docker.com/install/

## Instructions
1. Put your csv file in the Inputs directory  
2. Either name it `test.csv` or edit the Snakefile and change the name in the first rule.
3. Run `./start-script`. The docker image will download automatically the first time you run the script.
4. After successful execution the graph is found in the Outputs folder.

## Some comments
At the moment the first snakemake rule is nonsensical since it only copies a file from the Inputs directory to the Outputs directory, it's there because I use it to copy files straight from the Accu-Chek meter.
