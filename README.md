# covid-global

> **Archived.** No longer maintained; last updated July 2020. It depends on the retired `EpiNow` and `NCoVUtils` packages and on ECDC case data as published at the time.

Results store for the national Rt estimates shown on the epiforecasts COVID-19 website, held as a submodule of epiforecasts/covid. It was started afresh in June 2020; earlier results are in epiforecasts/covid-global-archive. Later estimates are in epiforecasts/covid-rt-estimates.

- `update_nowcasts.sh`: runs `update_nowcasts.R` (Rt from ECDC case counts) and `update_deaths_nowcasts.R` (Rt from deaths).
- `national/`: per-country estimates, plots and forecasts, with the most recent run in `latest/`.
- `national-summary/`: cross-country summary tables, plots and `rt.csv`.
- `deaths/`: the same outputs based on deaths.
- `data/`: the onset-to-death delay and spreadsheets of data for Japan and Singapore.
