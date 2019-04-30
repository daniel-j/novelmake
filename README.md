# novelmake


## Getting Started

Install the following dependencies:

- Ubuntu: `make zip unzip texlive-latex-extra texlive-luatex texlive-lang-french texlive-fonts-extra fontconfig imagemagick ghostscript python3-lxml python3-cssutils python3-cssselect`
- Arch Linux: `make zip unzip texlive-latexextra fontconfig imagemagick ghostscript python-lxml python-cssutils python-cssselect`
- macOS and Windows: To be continued...

You need a pdf reader. On Linux I like to use [Evince](https://wiki.gnome.org/Apps/Evince) but there are more lightweight pdf readers available. On macOS, Preview should work good enough.

Optional, but if you decide to make an ebook with your pdf book (recommended!) you need an EPUB viewer and an EPUB editor. I recommend using [Calibre's ebook-viewer](https://manual.calibre-ebook.com/viewer.html) and [Sigil](https://sigil-ebook.com/) for editing the ebook. Of course, you can edit the files as they are in the EPUB tree, but I like sticking to Sigil. It has some great features such as search/replace with strings and regular expressions, spellchecking, prettifying HTML and managing metadata when managing text/image/font/style files.

This repository uses submodules, clone it with the following command:

`git clone --recurse-submodules https://github.com/daniel-j/novelmake.git`
