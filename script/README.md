# Install/script/startup scripts

```
curl -O https://raw.githubusercontent.com/hajimeo/LogAnalyser/master/resources/Dockerfile
# Modify the "RUN sed ..." to use Nexus's apt-proxy repository
docker build -t log-analyser .
docker run -tid -p 8888-8999:8888-8999 \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/tmp/share:/var/tmp/share \
  --privileged=true --name=log-analyser log-analyser /sbin/init
```
