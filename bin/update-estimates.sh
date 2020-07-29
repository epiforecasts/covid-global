#!/bin/bash

## Run case based update
Rscript R/update_cases.R

## Run death based update
Rscript R/update_deaths.R