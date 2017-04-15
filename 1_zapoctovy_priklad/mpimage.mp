prologues:=3;
filenametemplate "%j-%3c.mps";

verbatimtex 
\documentclass{minimal}
\usepackage[resetfonts]{cmap}
\usepackage{lmodern}
\usepackage[czech]{babel}
\usepackage[T1]{fontenc}
\begin{document}
etex; 

polomer:= 2cm;
beginfig(1);

	z1 = (0 , polomer);
	z2 = (polomer, 0);
	z3 = (2polomer, polomer);
	z4 = (polomer, 2polomer);
	
	z5 = (polomer, polomer);
	
	z6 = (polomer, 1.5polomer);
	z7 = (polomer, 0.5polomer);

	path p;

	p = z4..z3..z2;

	fill p{left}..z5{right}..{left}cycle;
	draw p..z1..cycle;

	fill fullcircle scaled 0.25polomer shifted z6;
	fill fullcircle scaled 0.25polomer shifted z7 withcolor white;
endfig;
end;