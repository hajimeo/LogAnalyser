# LogAnalyser
Set of functions and UIs to convert log files to CSV or JSON, then load to SQLite (or H2?).
The size of log files should be less than 100 MB (analysing large text is outside of scope).

## Components
* Setup script (bash), which should be reusalbe in Dockerfile
* Frontend service (PHP, HTML, Javascript)
* (Backend) API service (PHP, Python, or Golang?)
* (Backend) job/task service (bash, python, sqlite, docker)

### Setup script
* A simple bash script to install/setup if the first time.
* Start / stop all components.
* How to bootstrap the setup script is currently thinking of using git clone.

### Frontend service
Frontend service delivers HTMLs pages with Javascripts for the following activities:
* Allow user to choose (like 'cd') log files location in the server
* Input box to type a glob string to filter files
* Specify date range and keywords (eg.: UUID)
* Provide links to analyse data (Jupyter, Superset, ~~Redash, metabase~~)
* Provide an input or inputs to save rules which map regex result in a text line to fields (database columns)
* Format long/complex analysis results with server-side language (easier than doing in javascript)
* (Optional) Profide UI to add / change system settings (can be simple JSON string, like VS Code)

### API service
Lite API service, which translates requests from/to Frontend service(s) and other backend services.
What it does are:
* Provide multi-processing capability
* Save necessary requests to some permanent storage (json files, no plan of using DB)
* Convert requests and transfer to other services which do not have any REST API (eg: Task scheduling service)
* Receive other services' results and store, where Frontend service is accessible (or responds if Frontdend requests).
NOTE: most of actual tasks would be done by Task service.

### Task service
In charge of executing background / asynchronous type requests.
Utilise OS dependant commands and scripts (bash, python) to run on-demand or scheduled jobs (cron, at), but should be designed to be replacable with better schedular.
Example of jobs are:
* Pull log file from a remote server to the specified location regularly (sftp, scp. rsync).
* Based on specified path/file and glob rule, find matching files and convert to sqlite friendly format (rg)
* Load data into specified database, if API service has some difficulty to handle.

## Future plans
May be addking some business/software specific tasks
* Generate dummy data
