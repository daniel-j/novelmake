FROM ubuntu:bionic

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    make zip unzip bash-completion \
    texlive-latex-extra texlive-luatex texlive-lang-french texlive-fonts-extra fontconfig \
    imagemagick ghostscript \
    python3-lxml python3-cssutils python3-cssselect

RUN apt-get clean

ENV TEXMFVAR /workspace/.texmf-var
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

VOLUME ["/workspace"]

CMD ["bash"]
