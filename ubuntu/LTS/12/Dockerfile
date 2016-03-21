# Dockerfile for building Ansible image for Ubuntu 12.04 (Precise LTS), with as few additional software as possible.
FROM ubuntu:12.04

MAINTAINER Valeriy Solovyov <weldpua2008@gmail.com>
RUN echo "===> Updating cache..." && \
    apt-get update && \
    \
    \
    echo "===> Installing nsd3..."  && \
    apt-get install -y  nsd3 && \
    \
    \
    apt-get clean

CMD ["/bin/bash"]