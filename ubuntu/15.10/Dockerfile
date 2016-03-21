# Dockerfile for building Ansible image for Ubuntu 15.10 (Wily Werewolf), with as few additional software as possible.

FROM ubuntu:15.10

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