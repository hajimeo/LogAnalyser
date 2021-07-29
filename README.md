# LogAnalyser
Providing functions to convert log files to CSV or JSON, and load into SQLite (TODO: or H2).  
The size of log files should be less than 100 MB (analysing large text is out of scope).

```
mkdir -m 777 -p /var/tmp/share/loganalyser
curl -O https://raw.githubusercontent.com/hajimeo/LogAnalyser/master/resources/Dockerfile
# Modify the "ENV ..." to use Nexus's apt-proxy and pypi-proxy repositories
docker build -t log-analyser .
docker run -tid -p 8888-8999:8888-8999 \
  --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v /var/tmp/share:/var/tmp/share \
  --name=log-analyser log-analyser /sbin/init
```
NOTE: If large memory, ' --mount type=tmpfs,destination=/tmp'
Now the jupyter lab should be listening on http://<hostname>:8999/login

NOTE: Sometimes 'jupyter.service' does not start somehow. In that case, please start with:  
```
# To check the service status
#docker exec log-analyser systemctl status jupyter.service
#docker exec log-analyser journalctl -u jupyter.service
docker exec log-analyser systemctl start jupyter.service
```
To force starting:
```
docker exec -d -u loganalyser log-analyser /home/loganalyser/.pyvenv/bin/jupyter-lab --no-browser --notebook-dir=/var/tmp/share/loganalyser --ip=0.0.0.0 --port=8999
```

# TODO and under development
Creating client script to push a zip or directory, analyse, and download the report.  
Creating a script to generate a report which shows findings and recommendations.  
Mac + Docker Desktop may not work or unstable with privileged=true.  
