#!/bin/bash

## Clean up any old docker containers with the same name
docker rm covidglobal

## Build the docker container
docker build . -t covidglobal