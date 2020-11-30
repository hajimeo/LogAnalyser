# LogAnalyser
Set of functions and UIs to convert log files to CSV or JSON, then load to SQLite (or H2?).
The size of log files should be less than 100 MB (analysing large text is outside of scope).

```
curl -O https://raw.githubusercontent.com/hajimeo/LogAnalyser/master/resources/Dockerfile
# Modify the "RUN sed ..." to use Nexus's apt-proxy repository
docker build -t log-analyser .
docker run -tid -p 8888-8999:8888-8999 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/tmp/share:/var/tmp/share \
  --privileged=true --name=log-analyser log-analyser /sbin/init
```

# TODO and under development
Creating client script to push a zip or directory, analyse, and download the report. 

Creating a script to generate a report which shows findings and recommendations. 
