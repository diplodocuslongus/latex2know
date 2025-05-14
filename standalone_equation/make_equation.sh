#!/bin/bash

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  

# This program was written by Dominic Hosler 
# There is a description of how it works on my blog https://dominichosler.wordpress.com

# Requires:
# apt install texlive-fonts-extra  texlive-extra-utils

# usage:
# make this script executable
# create a file with extension `.texpart` containing the LaTeX code of the equation to produce, for example 
# e^{i \pi}+1=0a (see example.texpart)
# call this script with:
#
#  ./make_equation.sh -v example.texpart
#
# It takes one optional argument, -v, to output the equations as vector graphics
# (pdf) or -i, to output as raster (png).
# The script will then remove the files it created (apart from the output file).
# Modifications: usage guide with example, option to save as svg

#Create temporary files for latex file
echo "Constructing LaTeX file"

echo "\documentclass{article}
\usepackage{amsmath,amssymb,bm,amsthm,bbold}
\usepackage{latexsym}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{mathrsfs}
\begin{document}
\pagestyle{empty}
\begin{equation*}" > part1.temp

echo "\end{equation*}
\end{document}
" > part3.temp

cat part1.temp $2 part3.temp > full.temp.tex

echo "Process the LaTeX file"
lualatex -interaction=batchmode full.temp.tex


#Test if the user has input the -v option (for vector) or -b (for bitmap)
while getopts "vpb" OPTION
do
case $OPTION in
p) #In the case of vector graphics, just crop the pdf with a small margin and output to correct filename.
  echo "Output set to vector graphics, pdf."
  pdfcrop --margins 5 full.temp.pdf ${2%\.*}.pdf
;;
v) #In the case of vector graphics, just crop the pdf with a small margin and output to correct filename.
  echo "Output set to vector graphics, svg."
  pdfcrop --margins 5 full.temp.pdf ${2%\.*}.pdf
  pdf2svg ${2%\.*}.pdf ${2%\.*}.svg
  # convert -density 300 -trim -scale 100% -background white -alpha remove ${2%\.*}.pdf ${2%\.*}.svg
;;
b) #In the case of bitmap graphics, crop the pdf with margin
  echo "Output set to bitmap graphics, png."
  pdfcrop --margins 5 full.temp.pdf full.temp.cropped.pdf
  #Then convert to a png with a high resolution for rasterisation.
  convert -density 500 full.temp.cropped.pdf ${2%\.*}.png
  rm full.temp.cropped.pdf
;;
\?) exit 1;;
esac
done

#Cleanup temp files
echo "Cleanup temporary files"

rm part1.temp part3.temp full.temp.tex full.temp.aux full.temp.log full.temp.pdf
