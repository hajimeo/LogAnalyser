FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl sudo
RUN curl -sf --compressed "https://raw.githubusercontent.com/hajimeo/samples/master/bash/setup_work_env.sh" -o $HOME/setup_work_env.sh
RUN bash $HOME/setup_work_env.sh