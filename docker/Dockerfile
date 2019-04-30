FROM ubuntu:bionic

RUN apt-get update

RUN apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
    make patch unzip bash-completion \
    texlive-latex-extra texlive-luatex texlive-lang-french texlive-fonts-extra fontconfig \
    graphicsmagick-imagemagick-compat ghostscript \
    python3-lxml python3-cssutils python3-cssselect

RUN apt-get clean

VOLUME ["/workspace"]

ENV TEXMFVAR /workspace/.texmf-var

CMD ["bash"]
