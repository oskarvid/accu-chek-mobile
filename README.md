# accu-chek-mobile
For analysis of blood glucose data from an Accu-Chek Mobile.

## Dependencies
Docker: https://docs.docker.com/install/

## Instructions
1. Put your csv file in the Inputs directory  
2. Either name it `test.csv` or edit the Snakefile and change the name in the first rule.
3. Run `./start-script`. The docker image will download automatically the first time you run the script.
4. After successful execution the graph is found in the Outputs folder.

## Some comments
At the moment the first snakemake rule is useless since it only copies a file from the Inputs directory to the Outputs directory, it's there because I use it to copy files straight from the Accu-Chek meter. You can do that too, because why not?

It's not adapted for large datasets, I have so far tested it with 80 data points just fine, I don't know where the upper limit is before the output graph isn't readable anymore. But at least the legend placement and Y-scale generation is dynamic, so it should be pretty plug and play, you just might have to create a smaller dataset if the graph comes out unreadable. 