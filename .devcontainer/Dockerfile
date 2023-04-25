FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y --no-install-recommends python3-pip git

COPY ./requirements.txt .

RUN pip3 install -r requirements.txt