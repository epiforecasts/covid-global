#!/bin/bash

## Clean up any old docker containers with the same name
sudo docker rm covidglobal

## Build the docker container
sudo docker build . -t covidglobal

## Make a results directory
mkdir results

## Update estimates in newly built docker container
sudo docker run --rm --user rstudio --mount type=bind,source=$(pwd)/results,target=/home/covidglobal covidglobal /bin/bash bin/update-estimates.sh

## Move newly produced results and clean up
mv -f results/cases cases
mv -f results/deaths deaths
rm -r -f results