# novelmake

This repo is a work in progress.

Create pretty books using the [`novel`](https://www.ctan.org/pkg/novel) LaTeX documentclass. This is for typesetting novels and has been used in various small scale printing projects. This project's purpose is to get you started with it easily, and to assist your book making.

If you're only interested in making an ebook, check out the sibling project [epubmake](https://github.com/daniel-j/epubmake).

## Getting Started

Read a couple of parts of [`novel`'s documentation](http://mirrors.ctan.org/macros/luatex/latex/novel/doc/novel-documentation.html) before starting.

Install the following dependencies:

- Ubuntu: `make zip unzip texlive-latex-extra texlive-luatex texlive-fonts-extra texlive-lang-french fontconfig imagemagick graphicsmagick ghostscript python3-lxml python3-cssutils python3-cssselect`
- Arch Linux: `make zip unzip texlive-latexextra fontconfig imagemagick graphicsmagick ghostscript python-lxml python-cssutils python-cssselect`
- Windows: Install [Ubuntu for Windows 10](https://www.microsoft.com/en-us/p/ubuntu-1804-lts/9n9tngvndl3q) and install the Ubuntu dependencies. Clone the repo (recursively, see below) somewhere in `/mnt/c/Users/<your windows username>` so you can access the files with Explorer. [Screenshot of working setup.](https://images2.imgbox.com/af/f8/2CU9EKB8_o.png) This way you do not have to mess with getting LuaLaTeX, bash, make, python etc working on Windows. An other solution is to use the Docker container (not tested on Windows).
- macOS: To be continued...

You need a pdf reader. On Linux I like to use [Evince](https://wiki.gnome.org/Apps/Evince) but there are more lightweight pdf readers available. On macOS, Preview should work good enough.

Optional, but if you decide to make an ebook with your pdf book (recommended!) you need an EPUB viewer and an EPUB editor. I recommend using [Calibre's ebook-viewer](https://manual.calibre-ebook.com/viewer.html) and [Sigil](https://sigil-ebook.com/) for editing the ebook. Of course, you can edit the files as they are in the EPUB tree, but I like sticking to Sigil. It has some great features such as search/replace with strings and regular expressions, spellchecking, prettifying HTML and managing metadata when managing text/image/font/style files.

This repository uses submodules, clone it with the following command:

`git clone --recurse-submodules https://github.com/daniel-j/novelmake.git`

## Usage

The main TeX file is `book/book.tex`. XHTML files from the ebook are converted to TeX using the config in `tools/html2latex-novel.py`. Modify this to get the desired results, along with the CSS of the ebook. If you don't care about the ebook, you can change the chapter includes in `book.tex`. Run `make buildbook` to build the pdf. It will end up in the `build` directory. See the novel documentation for further information.

You can build the book cover (artwork/cover.png) with `make buildcover`. This uses novel's makecmyk script and creates a PDF/X-compliant cover in the build directory as `cover.pdf`. You need to modify `book/cover.tex` with the right mediasize, trimsize and metadata first! Use 300 dpi sRGB (no alpha) png. You can read more about the novel scripts [here](https://htmlpreview.github.io/?https://github.com/daniel-j/novel/blob/master/scripts/novel-scripts-README.html).

Place any images you want to use in the pdf book in the `artwork` directory. PNG and JPG files only. File names ending with `-bw.*` will get turned into 1-bit black and white images. Use a high resolution for b/w images, at least 600 dpi. Other images will get turned into grayscale. These should be 300 dpi. Converted images appear in `build/artwork/`. Interior color images are not supported at the moment. Use separate images for the ebook and pdf, as you want more compression on the ebook images, while you want the highest quality possible for print images.
