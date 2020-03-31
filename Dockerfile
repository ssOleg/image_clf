FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y gnupg2
RUN apt-get install -y ca-certificates
RUN apt install -y python3-pip

RUN echo "deb [arch=amd64] http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal" | tee /etc/apt/sources.list.d/tensorflow-serving.list && curl https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg | apt-key add -

RUN apt-get update && apt-get install -y python3.7 && apt-get install -y tensorflow-model-server

RUN python3.7 -m pip install pip
COPY ./requirements.txt /app/requirements.txt
COPY ./app.py /app/app.py
COPY ./Makefile /app/Makefile
COPY ./models/ /models/
COPY ./start.sh /app/start.sh

WORKDIR /app
RUN python3.7 -m pip install -r requirements.txt

RUN apt update && apt-get -y install tmux
RUN apt update && apt-get -y install vim

RUN echo "alias start_services='cd /app/ && make start_services'" >> ~/.bashrc
RUN echo "alias restart_services='cd /app/ && make restart_services'" >> ~/.bashrc
RUN echo "alias stop_services='cd /app/ && make stop_services'" >> ~/.bashrc

RUN chmod +x /app/start.sh
