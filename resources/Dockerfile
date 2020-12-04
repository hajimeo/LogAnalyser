# HOW-TO: https://github.com/hajimeo/LogAnalyser
FROM ubuntu:20.04
# To specify Nexus apt and pypi proxy repositories (if not reachable, will be just ignored):
ENV _NXRM_APT_PROXY="http://dh1.standalone.localdomain:8081/repository/apt-proxy/"
ENV _NXRM_PYPI_PROXY="http://dh1.standalone.localdomain:8081/repository/pypi-proxy/"
RUN apt-get update; \
  apt-get install -y curl sudo; \
  curl -sf --compressed "https://raw.githubusercontent.com/hajimeo/LogAnalyser/master/script/setup.sh" -o /tmp/setup.sh; \
  bash /tmp/setup.sh; \
  rm -rf /var/lib/apt/lists/*