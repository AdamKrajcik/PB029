TEX_FILES = uvod.tex cv.tex odplist.tex
BIBLIO = literatura.bib
TEX = pdflatex
BIB = biber

.PHONY: all clean

all: clean odp.pdf

document.pdf: cv.pdf uvod.pdf
	pdflatex document.tex 
	
clean:
	-rm *.{aux,out,bcf,blg,ind,idx,bbl,log,run.xml,pdf,mps}

cv.pdf: photo.jpg cv.tex
	pdflatex cv.tex

uvod.pdf: mpimage--001.mps uvod.tex uvod.bbl uvod.ind 
	pdflatex uvod.tex

odp.pdf: document.pdf
	pdflatex odplist.tex

uvod.bbl: uvod.bcf
	biber uvod.bcf

uvod.ind: uvod.idx
	texindy -I latex --language czech --codepage utf8 uvod.idx
	
uvod.idx: uvod.tex
	pdflatex uvod.tex
	
uvod.bcf: uvod.tex literatura.bib
	pdflatex uvod.tex

mpimage--001.mps: mpimage.mp
	mpost -tex=latex mpimage.mp
