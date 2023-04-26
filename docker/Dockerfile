FROM nvcr.io/nvidia/pytorch:22.08-py3
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends git

COPY ./requirements.txt .

RUN pip3 install -r requirements.txt