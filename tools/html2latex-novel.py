#!/usr/bin/env python3

import re
import sys
import os.path

sys.path.append(os.path.join(os.path.dirname(__file__), 'html2latex'))
from html2latex import Html2Latex

# this is made with the novel class in mind.

replacements_head = {}
replacements_tail = {}

# Available options: hyperref, footnotes or None
hyperlinks = None


def s(start='', end='', ignoreStyle=False, ignoreContent=False):
    # helper for generating the selector objects
    return {
        'start': start,
        'end': end,
        'ignoreStyle': ignoreStyle,
        'ignoreContent': ignoreContent
    }


def handle_anchor(selector, el):
    href = el.get('href')
    name = el.get('name')

    if hyperlinks == 'hyperref':
        start = ''
        end = ''
        if href and href.startswith('#'):
            start = '\\hyperlink{' + href[1:] + '}{'
            end = '}'
        elif name:
            start = '\\hypertarget{' + name + '}{'
            end = '}'
        elif href:
            start = '\\href{' + href + '}{'
            end = '}'
        return s(start, end)
    elif hyperlinks == 'footnotes':
        if href and not href.startswith('#'):
            return s(end='\\footnote{' + href + '}')
    return None


def handle_nbsp(el, pos, char):
    if el.get('class') == 'chapter-number':
        return '~\\,~'
    return '~'


def handle_img(selector, el):
    name = os.path.basename(el.get('src'))
    name = name.replace('-bw.jpg', '-bw.png')
    return s('\\FloatImage{' + os.path.join('build/artwork', name) + '}\n')


# Available options: hyperref, footnotes or None
hyperlinks = None

selectors = {
    # defaults
    'html': s('\\thispagestyle{empty}\n{\n', '\n}\n'),
    'head': s(ignoreContent=True, ignoreStyle=True),
    'body': s('\n\n', '\n\n\\clearpage\n\n'),
    'blockquote': s('\n\\begin{quotation}', '\n\\end{quotation}'),
    'ol': s('\n\\begin{enumerate}', '\n\\end{enumerate}'),
    'ul': s('\n\\begin{itemize}', '\n\\end{itemize}'),
    'li': s('\n\t\\item '),
    'i': s('\\textit{', '}', ignoreStyle=True),
    'b, strong': s('\\textbf{', '}', ignoreStyle=True),
    'em': s('\\emph{', '}', ignoreStyle=True),
    'u': s('\\underline{', '}', ignoreStyle=True),
    'sub': s('\\textsubscript{', '}'),
    'sup': s('\\textsuperscript{', '}'),
    'br': s('~\\\\\n'),
    'hr': s('\n\n\\line(1,0){300}\n', ignoreStyle=True),
    'a': handle_anchor,
    'img': handle_img,

    # customized
    'p': s('\n\n'),
    '.chapter-name': s('\n\n\\noindent\\hfil\\charscale[2,0,-0.1\\nbs]{', '}\\hfil\\newline\n\\vspace*{1\\nbs}\n\n', ignoreStyle=True),
    '.center': s('\n\n{\\csname @flushglue\\endcsname=0pt plus .25\\textwidth\n\\noindent\\centering{}', '\\par\n}', ignoreStyle=True),
    '.vfill': s('\n\n\\vspace*{\\fill}', '', ignoreContent=True, ignoreStyle=True)
}

characters = {
    u'\u00A0': handle_nbsp, # &nbsp;
    u'\u2009': '\\,', # &thinsp;
    u'\u2003': '\\hspace*{1em}', # &emsp;
    '[': '{[}',
    ']': '{]}'
}

styles = {
    # defaults
    'font-weight': {
        'bold': ('\\textbf{', '}'),
        'bolder': ('\\textbf{', '}')
    },
    'font-style': {
        'italic': ('\\textit{', '}')
    },
    'font-variant': {
        'small-caps': ('\\textsc{', '}')
    },
    'text-indent': {
        '0': ('\\noindent{}', ''),
        '-1em': ('\\noindent\\hspace*{-1em}', '')
    },
    'text-align': {
        'left': ('\n{\\raggedright{}', '}'),
        'center': ('\n{\\centering{}', '\\par}'),
        'right': ('\n{\\raggedleft{}', '}')
    },
    'text-wrap': {
        'balanced': ('{\\csname @flushglue\\endcsname=0pt plus .25\\textwidth\n', '\n}')
    },
    '-latex-needspace': {
        '2': ('\n\n\\needspace{2\\baselineskip}\n', '')
    },

    'display': {
        'none': s(ignoreContent=True, ignoreStyle=True)
    },

    # customized
    'margin': {
        '0 2em': ('\n\n\\begin{adjustwidth}{2em}{2em}\n', '\n\\end{adjustwidth}\n\n'),
        '0 1em 0 2em': ('\n\n\\begin{adjustwidth}{2em}{1em}\n', '\n\\end{adjustwidth}\n\n'),
        '0 1em': ('\n\n\\begin{adjustwidth}{2em}{2em}\n', '\n\\end{adjustwidth}\n\n')
    },
    'margin-top': {
        '1em': ('\n\n\\vspace{\\baselineskip}\n\\noindent\n', '')
    },
    'margin-bottom': {
        '1em': ('', '\n\n\\vspace{\\baselineskip}\n\\noindent\n')
    },
    'font-size': {
        '1.2em': ('\\charscale[1.2]{', '}')
    },
    '-latex-display': {
        'none': s(ignoreContent=True, ignoreStyle=True)
    }
}

html2latex = Html2Latex(
    selectors=selectors,
    characters=characters,
    styles=styles,
    replacements_head=replacements_head,
    replacements_tail=replacements_tail
).parse_args().run()
