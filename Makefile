
# EPUB/PDF Makefile helper by djazz
# https://github.com/daniel-j/novelmake
# Do not run this makefile's jobs in parallel/multicore (-j)

RELEASENAME = "My Book %y%m%d"

CURRENTEPUB = current.epub
SOURCE      = ./src/
EPUBFILE    = ./build/ebook.epub
KEPUBFILE   = ./build/ebook.kepub.epub
KINDLEFILE  = ./build/ebook.mobi
AZW3FILE    = ./build/ebook.azw3
PDFFILE     = ./build/book.pdf


SHELL := /bin/bash
SOURCEFILES = $(shell find $(SOURCE) | sort)
XHTMLFILES = $(shell find $(SOURCE) -name '*.xhtml' | grep -v 'nav\.xhtml\|cover\.xhtml\|title\.xhtml' | sort)
TEXPARTS = $(shell find $(SOURCE) -name '*.xhtml' | grep -v 'nav\.xhtml\|cover\.xhtml\|title\.xhtml' | sed -e 's/.*Text\/\(.*\)\.xhtml/.\/build\/latex\/\1.xhtml.tex/' | sort)
PDFPARTS = $(shell find $(SOURCE) -name '*.xhtml' | grep -v 'nav\.xhtml\|cover\.xhtml\|title\.xhtml' | sed -e 's/.*Text\/\(.*\)\.xhtml/.\/build\/parts\/\1.pdf/' | sort)
PNGFILES = $(shell find $(SOURCE) -name '*.png' | sort)

ARTWORKFILES = $(shell find artwork -name '*.png' -or -name '*.jpg' | grep -v -w "artwork/cover.png" | sort | sed -e 's/^artwork\//.\/build\/artwork\//' -e 's/-bw\.jpg$$/-bw\.png/')

EPUBCHECK = ./tools/epubcheck/epubcheck.jar
KINDLEGEN = ./tools/kindlegen/kindlegen
LATEXNOVEL = ./tools/novel

EBOOKPOLISH := $(shell command -v ebook-polish 2>&1)
EBOOKVIEWER := $(shell command -v ebook-viewer 2>&1)
JAVA        := $(shell command -v java 2>&1)
INOTIFYWAIT := $(shell command -v inotifywait 2>&1)

EPUBCHECK_VERSION = 4.2.1
# https://github.com/IDPF/epubcheck/releases
EPUBCHECK_URL = https://github.com/IDPF/epubcheck/releases/download/v$(EPUBCHECK_VERSION)/epubcheck-$(EPUBCHECK_VERSION).zip
# http://www.amazon.com/gp/feature.html?docId=1000765211
KINDLEGEN_URL_LINUX = http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz

.PRECIOUS: build/latex/%.xhtml.tex
.PHONY: all clean validate build buildkepub buildkindle buildcover buildbook buildtexparts buildpdfparts buildartwork extractcurrent watchcurrent release publish
all: build
release: clean build validate buildkepub buildkindle

build: $(EPUBFILE)
$(EPUBFILE): $(SOURCEFILES)
	@echo "Building EPUB..."
	@mkdir -p `dirname $(EPUBFILE)`
	@rm -f "$(EPUBFILE)"
	@cd "$(SOURCE)" && zip -Xr9D "../$(EPUBFILE)" mimetype
	@cd "$(SOURCE)" && zip -Xr9D "../$(EPUBFILE)" . -x mimetype -x "*.DS_Store"

buildkepub: $(KEPUBFILE)
$(KEPUBFILE): $(EPUBFILE) $(SOURCEFILES)
	@echo "Building Kobo EPUB..."
	@cp -f "$(EPUBFILE)" "$(KEPUBFILE)"
	@for current in $(XHTMLFILES); do \
		mkdir -p "$$(dirname "tmp/$$current")"; \
		echo "Kepubifying $$current..."; \
		./tools/kepubify.py "$$current" > "tmp/$$current"; \
	done
	@cd "tmp/$(SOURCE)" && zip -Xr9D "../../$(KEPUBFILE)" .
	@rm -rf "tmp/"

buildkindle: $(KINDLEFILE)
$(KINDLEFILE): $(EPUBFILE) $(KINDLEGEN)
	@echo Building Kindle file...
	@cp -f "$(EPUBFILE)" "$(KINDLEFILE).epub"
	@for current in $(PNGFILES); do \
		channels=$$(identify -format '%[channels]' "$$current"); \
		if [[ "$$channels" == "graya" ]]; then \
			mkdir -p "$$(dirname "tmp/$$current")"; \
			echo "Converting $$current to RGB..."; \
			convert "$$current" -colorspace rgb "tmp/$$current"; \
		fi; \
	done
	@cd "tmp/$(SOURCE)" && zip -Xr9D "../../$(KINDLEFILE).epub" . || exit 0
	@rm -rf "tmp/"
	@$(KINDLEGEN) "$(KINDLEFILE).epub" -dont_append_source -c1 || exit 0 # -c1 means standard PalmDOC compression. -c2 takes too long but probably makes it even smaller.
	@rm -f "$(KINDLEFILE).epub"
	@mv "$(KINDLEFILE).mobi" "$(KINDLEFILE)"

buildazw3: $(AZW3FILE)
$(AZW3FILE): $(EPUBFILE)
	@echo Building Kindle AZW3 file...
	ebook-convert "$(EPUBFILE)" "$(AZW3FILE)" --pretty-print --no-inline-toc --max-toc-links=0 --disable-font-rescaling --cover=./src/OEBPS/Images/cover.jpg --book-producer=djazz

# Builds the LaTeX files from XHTML
build/latex/%.xhtml.tex: src/OEBPS/Text/%.xhtml src/OEBPS/Styles/style.css tools/html2latex-novel.py
	@mkdir -p "build/latex/"
	python3 -B tools/html2latex-novel.py --style "src/OEBPS/Styles/style.css" --input "$<" --output "$@"

buildtexparts: $(TEXPARTS)

build/tex/impnattypo/impnattypo.sty: tools/impnattypo/impnattypo.ins tools/impnattypo/impnattypo.dtx
	@rm -rf build/tex/impnattypo
	@mkdir -p build/tex/impnattypo
	@cd tools/impnattypo && latex -draftmode -output-directory=../../build/tex/impnattypo impnattypo.ins

# Builds the PDF from LaTeX files
$(PDFFILE): $(LATEXNOVEL) $(TEXPARTS) book/* build/tex/impnattypo/impnattypo.sty tools/novel/* buildartwork
	@echo Building book...
	@tools/novelrun book/book.tex
	@touch $(PDFFILE)

buildbook: $(PDFFILE)

build/parts/%.pdf: $(LATEXNOVEL) build/latex/%.xhtml.tex book/* tools/novel/*
	@echo Building part $*.pdf...
	@mkdir -p build/parts
	@TEXINPUTS=./tools/novel/:$(kpsewhich -var-value TEXINPUTS) tools/latexrun --latex-cmd lualatex --latex-args="--jobname=\"$*\"" -Wall -Wno-fontspec --verbose-cmds -O "build/.parts/$*" -o "$@" book/single.tex
	@touch "$@"

buildpdfparts: $(PDFPARTS)

buildcover: build/cover.pdf
build/cover.pdf: artwork/cover.png book/cover.tex
	@echo Making book cover...
	@cd tools/novel/scripts && ./makecmyk ../../../../artwork/cover.png
	@tools/novelrun ./book/cover.tex
	@mv tools/novel/scripts/output/cover-softproof.tif tools/novel/scripts/output/cover-NOTpdfx.pdf build/

define BUILDARTWORK
	@echo Converting image "$<" to "$@"
	@mkdir -p build/artwork
	@name="$$(basename "$<")"; \
	noext="$${name%.*}"; \
	ext="$${name##*.}"; \
	if [[ "$<" == *"-bw."* ]]; then \
		(cd tools/novel/scripts && ./makebw "../../../../$<"); \
		mv -v "tools/novel/scripts/output/$$noext-"*"-BW.png" "$@"; \
	else \
		(cd tools/novel/scripts && ./makegray "../../../../$<"); \
		mv -v "tools/novel/scripts/output/$$noext-"*"-GRAY.$$ext" "$@"; \
	fi
endef

build/artwork/%-bw.png: artwork/%-bw.png
	$(BUILDARTWORK)
build/artwork/%-bw.png: artwork/%-bw.jpg
	$(BUILDARTWORK)
build/artwork/%.png: artwork/%.png
	$(BUILDARTWORK)
build/artwork/%.jpg: artwork/%.jpg
	$(BUILDARTWORK)
buildartwork: $(ARTWORKFILES)
	@echo All images converted!


$(EPUBCHECK):
	@echo Downloading epubcheck...
	@curl -o "epubcheck.zip" -L "$(EPUBCHECK_URL)" --connect-timeout 30
	@mkdir -p `dirname $(EPUBCHECK)`
	@unzip -q "epubcheck.zip"
	@rm -rf `dirname $(EPUBCHECK)`
	@mv "epubcheck-$(EPUBCHECK_VERSION)" "`dirname $(EPUBCHECK)`"
	@rm epubcheck.zip

$(KINDLEGEN):
	@echo Downloading kindlegen...
	@curl -o "kindlegen.tar.gz" -L "$(KINDLEGEN_URL_LINUX)" --connect-timeout 30
	@mkdir -p `dirname $(KINDLEGEN)`
	@tar -zxf "kindlegen.tar.gz" -C `dirname $(KINDLEGEN)`
	@rm "kindlegen.tar.gz"


validate: $(EPUBFILE) $(EPUBCHECK)
ifndef JAVA
	@echo "Warning: Java was not found. Unable to validate ebook."
else
	@echo "Validating EPUB..."
	@$(JAVA) -jar "$(EPUBCHECK)" "$(EPUBFILE)"
endif


optimize: $(EPUBFILE)
ifndef EBOOKPOLISH
	@echo "Warning: Calibre was not found. Skipping compression."
else
	@echo "Compressing images and subsetting fonts. This may take a while..."
	@ebook-polish --verbose --compress-images --subset-fonts "$(EPUBFILE)" "$(EPUBFILE)"
endif


view: $(EPUBFILE)
ifndef EBOOKVIEWER
	@echo "Warning: Calibre was not found. Unable to open ebook viewer."
else
	@ebook-viewer --detach "$(EPUBFILE)"
endif


clean:
	rm -f "$(EPUBFILE)"
	rm -f "$(KEPUBFILE)"
	rm -f "$(KINDLEFILE)"
	rm -f "$(AZW3FILE)"
	rm -rf build/.book build/parts build/.parts build/latex
	rm -rf build/artwork
	@# only remove dir if it's empty:
	@(rmdir `dirname $(EPUBFILE)`; exit 0)


extractcurrent: $(CURRENTEPUB)
	@echo "Extracting $(CURRENTEPUB) into $(SOURCE)"
	@rm -rf "$(SOURCE)"
	@mkdir -p "$(SOURCE)"
	@unzip "$(CURRENTEPUB)" -d "$(SOURCE)"

watchcurrent: $(CURRENTEPUB) $(EPUBCHECK)
ifndef JAVA
	$(error Java was not found. Unable to validate ebook)
endif
ifndef INOTIFYWAIT
	$(error inotifywait was not found. Unable to watch ebook for changes)
endif
	@echo "Watching $(CURRENTEPUB)"
	@while true; do \
		$(INOTIFYWAIT) -qe close_write "$(CURRENTEPUB)"; \
		echo "Validating $(CURRENTEPUB)..."; \
		$(JAVA) -jar "$(EPUBCHECK)" "$(CURRENTEPUB)"; \
	done

publish: $(EPUBFILE) $(KINDLEFILE) $(KEPUBFILE) $(AZW3FILE)
	@mkdir -pv release
	cp "$(EPUBFILE)" "release/$$(date +$(RELEASENAME)).epub"
	cp "$(KEPUBFILE)" "release/$$(date +$(RELEASENAME)).kepub.epub"
	cp "$(KINDLEFILE)" "release/$$(date +$(RELEASENAME)).mobi"
	cp "$(AZW3FILE)" "release/$$(date +$(RELEASENAME)).azw3"
