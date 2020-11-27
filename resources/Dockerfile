FROM ubuntu:20.04
# To use my Nexus
#RUN sed -i.bak 's@http://archive.ubuntu.com/ubuntu/@http://dh1.standalone.localdomain:8081/repository/apt-proxy/@g' /etc/apt/sources.list
RUN apt-get update; \
  apt-get install -y curl sudo; \
  curl -sf --compressed "https://raw.githubusercontent.com/hajimeo/LogAnalyser/master/script/setup.sh" -o /tmp/setup.sh; \
  bash /tmp/setup.sh
#  bash /tmp/setup.sh -a http://dh1.standalone.localdomain:8081/repository/pypi-proxy/

#curl -O https://raw.githubusercontent.com/hajimeo/LogAnalyser/master/resources/Dockerfile
#docker build -t log-analyser .
#docker run -tid -p 8888-8999:8888-8999 -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/tmp/share:/var/tmp/share --privileged=true --name=log-analyser log-analyser /sbin/init