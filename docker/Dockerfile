FROM ubuntu:bionic

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    less nano bash-completion \
    make zip unzip \
    texlive-latex-extra texlive-luatex \
    imagemagick graphicsmagick ghostscript \
    python3-lxml python3-cssutils python3-cssselect

RUN apt-get clean && apt-get autoclean

ENV TEXMFVAR /workspace/.texmf-var

VOLUME ["/workspace"]

CMD ["bash"]
