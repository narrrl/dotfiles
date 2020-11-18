#!/bin/bash

if (($# != 1)); then
    printf "Error: No file name provided\n"
    exit 2
else
    touch ./$1 && echo "
\\documentclass[12pt]{article}

\\usepackage[utf8]{inputenc}
\\usepackage{amsmath}
\\usepackage{amssymb}
\\usepackage{xcolor}
\\usepackage{tikz}

\\begin{document}
\\end{document}" > ./$1
    exit 1
fi
