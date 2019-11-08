# accu-chek-mobile
[![Travis Build Status](https://img.shields.io/travis/oskarvid/accu-check-mobile.svg?logo=travis)](https://travis-ci.org/oskarvid/accu-check-mobile)  
For analysis of blood glucose data from an Accu-Chek Mobile.

## Features
Keep in mind that not everything can be plotted if you have too few data points. The minimum to plot everything is 163 data points. The legend will still refer to the lines that may be missing if you have too few data points.  
1. Colors alternate between days to allow for easy differentiation between one day and another.  
2. If the user correctly marks each blood glucose measurement it will show in the graph, see the sample graph for an example. This makes it easier to spot potential patterns.  
3. 24h plot can reveal general trends from eating habits.  
4. Histogram can tell if the readings lean more to the upper or lower range.

![Example graph1](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-graph.png)

![Example graph2](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-24h-bg-graph.png)

![Example graph3](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-24h-bg-graph-2.png)

![Example graph4](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-histogram.png)

![Example graph5](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-all-first-values-per-day.png)

![Example graph6](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-all-highest-values-per-day.png)

![Example graph7](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-all-last-values-per-day.png)

![Example graph8](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-all-lowest-values-per-day.png)

![Example graph9](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-candle-chart.png)

![Example graph10](https://raw.githubusercontent.com/oskarvid/accu-chek-mobile/master/.sample-day-plot.png)


These example graphs were generated with normally distributed random data.

## Dependencies
Install instructions for docker: https://docs.docker.com/install/

## Instructions
1. Put your csv file in the Inputs directory  
2. Either name it `test.csv` or edit the Snakefile and change the name in the first rule.
3. Run `./start-script`. The docker image will download automatically the first time you run the script.
4. After successful execution the graph is found in the Outputs folder.

## Some comments
At the moment the first snakemake rule is nonsensical since it only copies a file from the Inputs directory to the Outputs directory, it's there because I use it to copy files straight from the Accu-Chek meter.
