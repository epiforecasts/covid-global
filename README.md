
# National level estimates of the time-varying reproduction number for Covid-19

This repository contains estimates of the time-varying reproduction number for every country in the world listed in the ECDC Covid-19 data source. Summarised estimates can be found in `cases/summary` and `deaths/summary` (based on cases and deaths respectively). 

## Updating the estimates

1. Clone the repository.

```bash
git clone https://github.com/epiforecasts/covid-global.git
```

### Docker

2. Log in to GitHub Docker package repository.

```bash
docker login docker.pkg.github.com
```

#### Script approach

3. Run the following in a bash terminal

```bash
sudo bash update-via-docker.sh
```

#### Step by step


4. (Optional) Build the docker container locally.

```bash
docker build . -t covidglobal
```

5. (Optional). Alternatively pull the built docker container

```bash
docker pull docker.pkg.github.com/epiforecasts/covidglobal/covidglobal:latest
docker tag docker.pkg.github.com/epiforecasts/covidglobal/covidglobal:latest covidglobal
```

6. Update the estimates (saving the results to a results folder)

```bash
mkdir results
docker run --rm --user rstudio --mount type=bind,source=$(pwd)/results,target=/home/covidglobal covidglobal /bin/bash bin/update-estimates.sh
```

7. Clean up estimates and remove the temporary folder.

```bash
mv -r -f results/cases cases
mv -r -f results/deaths deaths
rm -r -f results
```

### Locally in R

2. Install dependencies.

```r
devtools::install_dev_deps()
```

3. Update estimates

```r
Rscript R/update-cases.R
Rscript R/update-deaths.R
```

## Development environment

This analysis was developed in a docker container based on the `epinow2` docker image.

To build the docker image run (from the `covidglobal` directory):

``` bash
docker build . -t covidglobal
```

Alternatively to use the prebuilt image first login into the GitHub package repository using your GitHub credentials (if you have not already done so) and then run the following:

```bash
# docker login docker.pkg.github.com
docker pull docker.pkg.github.com/epiforecasts/covidglobal/covidglobal:latest
docker tag docker.pkg.github.com/epiforecasts/covidglobal/covidglobal:latest covidglobal
```
To run the docker image run:

``` bash
docker run -d -p 8787:8787 --name covidglobal -e USER=covidglobal -e PASSWORD=covidglobal covidglobal
```

The rstudio client can be found on port :8787 at your local machines ip.
The default username:password is covidglobal:covidglobal, set the user with -e
USER=username, and the password with - e PASSWORD=newpasswordhere. The
default is to save the analysis files into the user directory.

To mount a folder (from your current working directory - here assumed to
be `tmp`) in the docker container to your local system use the following
in the above docker run command (as given mounts the whole `covidglobal`
directory to `tmp`).

``` bash
--mount type=bind,source=$(pwd)/tmp,target=/home/covidglobal
```

To access the command line run the following:

``` bash
docker exec -ti covidglobal bash
```