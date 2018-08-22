# LogAnalyser
Actually, this tool is for preparing text (log) files to analyse other open source tools.
The size of log files should be less than a few GB (no plan of using BigData related data warehouse)

## Components

* Setup script (bash)
* Frontend server (PHP, HTML, Javascript)
* (Backend) API server (Scala? or Golang?)
* (Backend) job server (bash, python, sqlite, docker)

## Setup script
* A simple bash script to start all components.
* How to install is basically git clone.
* Prepare docker container

## Frontend server
Frontend server delivers HTMLs and Javascripts to browser for the following activities:

* Select (not free typing) a log file location in the server (one gz file or one directory)
* Input box to type a glob string to filter files
* Specify date range and keywords (eg.: UUID)
* Provide links to analyse data (Jupyter, Superset, Redash, metabase)
* Provide an input to save rules which map strings in a text line to fields (database columns)
* Format long/complex job result and pass to browser (easier than doing in javascript)
* Adding/Changing system settings (optional. can be simple JSON files)

## API server
API server communicates with mainly client's browser and frontend server. And what it does are:

* Provide multi-processing capability
* save user input to some permanent storage (json files, no plan of using DB)
* pass user's request to Job server (not REST API)
* receive job server's result and store
* browser requests the result directly (for simple result) or via frontend (for complicated result)

## Job server
Job server is actually bunch of bash/python scripts to run on-demand and scheduled jobs (cron and/or at).

Main jobs are:
* Copy gz files from remote server to a local location regularly.
* Based on user specified path/file, find glob matching files and convert to one sqlite file
* Start/stop/restart container for open source tools.
