%%
%% Název: Tisk zadání se strojově čitelnými údaji
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{scanexam}
[2009/01/12 version 0.5 Machine readable information]

%%
%% Tato třída je založena na LaTeXovské třídě 'article'. Podporované volby
%% třídy 'article' jsou pouze draft/final a 10pt/11pt/12pt.
%%

\def\clsopt@status{final}
\def\clsopt@fntsize{11pt}

\DeclareOption{draft}{\def\clsopt@status{draft}}
\DeclareOption{final}{\def\clsopt@status{final}}

\DeclareOption{10pt}{\def\clsopt@fntsize{10pt}}
\DeclareOption{11pt}{\def\clsopt@fntsize{11pt}}
\DeclareOption{12pt}{\def\clsopt@fntsize{12pt}}

\ProcessOptions

\LoadClass[a4paper,oneside,\clsopt@status,\clsopt@fntsize]{article}


%%
%% Implementace strojově čitelných prvků - rozměry
%%

% Strojově čitelné informace se skládají z obdélníčků:
\newdimen\size@rect@length      \size@rect@length=5mm    % délka
\newdimen\size@rect@thick       \size@rect@thick=0.8mm   % tloušťka

% Pokud informaci vyplňuje člověk, je nutné mu obdélníčky naznačit. K tomu
% se jejich rohy vyznačí čarou následující tloušťky.
\newdimen\size@marg@thick       \size@marg@thick=0.1pt

% Délka čáry vyznačující vnitřní roh šablony ve čtvercové síti
% z elementárních obdélníčků.
\newdimen\size@marg@inner       \size@marg@inner=0.2mm

% Pokud po sobě následuje více elementárních políček (číslice, zaškrtávací
% políčko), jsou odděleny následující mezerou.
\newdimen\size@elem@skip        \size@elem@skip=2mm

% Každá strojově čitelná informace na stránce musí být doplněna
% synchronizačními značkami na okraji. Synchronizační značky jsou od okrajů
% tiskového zrcadla odsazeny následující mezerou.
\newdimen\size@sync@skip        \size@sync@skip=8mm

% Posun ve čtvercové síti z elementárních obdélníčků (užitečné například
% pro pole číslice).
\newdimen\size@rect@shift

% Přepočítání dopočítávaných rozměrů podle aktuálních hodnot.
\def\size@refresh{%
    \size@rect@shift=\size@rect@length
    \advance\size@rect@shift by -\size@rect@thick
}

% Iniciální refresh.
\size@refresh


%%
%% Styly
%%

% Popis datové položky.
\def\fielddesc@topstyle{\small\itshape\bfseries}



%%
%% Pomocná makra - řetězce bitů
%%
%% Následující makra implementují zpracování bitových řetězců. Primárním
%% účelem je vykreslování obdélníčků v šabloně. Obdélníčky tvořící šablonu
%% jsou očíslovány. Makro kreslící šablonu potom v argumentu bere bitový
%% řetězec, jehož délka odpovídá počtu obdélníčků v šabloně. Bit na i-té
%% pozici určuje, zda je i-tý obdélníček vykreslen nebo ponechán prázdný.
%%
%% Použití:
%% Volající makro musí nejprve uložit bitový řetězec do makra
%% \bit@sequence. Následně může opakovaně volat makro \bit@test. Opakovaná
%% volání \bit@test prochází postupně (a destruktivně) posloupností
%% v \bit@sequence. Pokud je hodnota aktuálního bitu 1, makro \bit@test
%% expanduje na svůj argument, jinak jej zahodí. Makro \bit@test svůj
%% argument zahazuje také po vyprázdnění \bit@sequence.

% Srovnávací hodnota - bit je nula.
\def\bit@zero{0}

% Srovnávací hodnota - bit je jedna.
\def\bit@one{1}

% Proměnná pro uložení posloupnosti bitů.
\def\bit@sequence{}

% Pomocná proměnná do níž je posouván pro zpracování první prvek
% posloupnosti.
\def\bite@now{}

% Posune posloupnost v \bit@sequence a odstraněný bit uloží do \bit@now.
\def\bit@take #1#2\relax{%
    \def\bit@now{#1}%
    \def\bit@sequence{#2}%
}

% Zavolá \bit@take a podle následného obsahu \bit@now expanduje na svůj
% argument nebo prázdnou posloupnost tokenů.
\def\bit@test#1{%
    \expandafter\bit@take\bit@sequence\relax\relax
    \ifx \bit@now\bit@one #1\fi
}


%%
%% Pomocná makra - cykly přes \relax-terminated posloupnosti tokenů
%%

% Srovnávací hodnota pro rozpoznání konce posloupnosti.
\def\loop@relax{\relax}

% Pomocné makro zahodí svůj argument (při ukončení cyklu).
\def\loop@droparg#1{}

% Pomocné makro zahodí zbytek \relax-terminated posloupnosti (při ukončení
% cyklu).
\def\loop@droprelax#1\relax{}


%%
%% Implementace strojově čitelných prvků - elementární obdélníčky
%%
%% Všechny strojově čitelné informace se skládají z jediného typu
%% obdélníčků, který má však dvě orientace:
%%      - horizontální (_) a
%%      - vertikální (|)
%% Následující dvě makra slouží k vykreslení těchto obdélníčků se spodní
%% hranou zarovnanou na baseline řádku do boxu šířky 0pt (usnadňuje
%% skládání prvků z více obdélníčků).

% Horizontální obdélníček.
\def\rect@h{%
    \hbox to 0pt{%
        \vrule width \size@rect@length height \size@rect@thick depth 0pt\hss
    }%
}

% Vertikální obdélníček.
\def\rect@v{%
    \hbox to 0pt{%
        \vrule width \size@rect@thick height \size@rect@length depth 0pt\hss
    }%
}


%%
%% Implementace strojově čitelných prvků - značky orientující stránku
%%
%% Oba horní rohy a levý dolní roh strojově snímatelné stránky musí
%% obsahovat vodící značky - čtverce velikosti elementárních obdélníčků.
%% Čtverce udávají jednak orientaci stránky, jednak rozměry tiskového
%% zrcadla a umístění ostatních vodících značek na stránce.
%%

% Makro se volá na začátku stránky, vytiskne vodící čtverce v horních
% rozích stránky.
\def\marks@top{%
    \vbox to \size@rect@length{%
        \offinterlineskip
        \hbox to \textwidth{%
            \hbox to 0pt{%
                \hss
                \vrule width \size@rect@length height \size@rect@length depth 0pt
                \kern\size@sync@skip
            }%
            \hfil
            \hbox to 0pt{%
                \kern\size@sync@skip
                \vrule width \size@rect@length height \size@rect@length depth 0pt
                \hss
            }%
        }%
    }%
}

% Makro se volá na konci stránky, vytiskne vodící čtverec v levém dolním
% rohu stránky.
\def\marks@bottom{%
    \hbox to \textwidth{%
        \hbox to 0pt{%
            \hss
            \vrule width \size@rect@length height \size@rect@length depth 0pt
            \kern\size@sync@skip
        }%
        \hfil
    }%
}


%%
%% Implementace strojově čitelných prvků - prvky okrajů
%%
%% Následující makra slouží k vyznačování tvarů vyskládaných z
%% elementárních obdélníčků. Motivována jsou šablonou přo číslici, ale měly
%% by postačit pro libovolný tvar, který lze z obdélníčků vyskládat.

% Levý okraj obdélníčku - přetéká vlevo.
\def\margin@lft{\hbox to 0pt{%
    \hss\vrule width \size@marg@thick height \size@rect@thick depth 0pt}}

% Pravý okraj obdélníčku - přetéká vpravo.
\def\margin@rt{\hbox to 0pt{%
    \vrule width \size@marg@thick height \size@rect@thick depth 0pt\hss}}

% Spodní levý okraj obdélníčku - přetéká vpravo.
\def\margin@llft{\hbox to 0pt{%
    \vrule width \size@rect@thick height 0pt depth \size@marg@thick\hss}}

% Horní levý okraj obdélníčku - přetéká vpravo.
\def\margin@ulft{\hbox to 0pt{%
    \raise \size@rect@thick \hbox{%
        \vrule width \size@rect@thick height \size@marg@thick depth 0pt}%
    \hss}}

% Spodní pravý okraj obdélníčku - přetéká vlevo.
\def\margin@lrt{\hbox to 0pt{%
    \hss\vrule width \size@rect@thick height 0pt depth \size@marg@thick}}

% Horní levý okraj obdélníčku - přetéká vpravo.
\def\margin@urt{\hbox to 0pt{%
    \hss \raise \size@rect@thick \hbox{%
        \vrule width \size@rect@thick height \size@marg@thick depth 0pt}%
    }}

% Vnitřní levý dolní roh.
\def\margin@inner@llft{\hbox to 0pt{\hskip \size@rect@thick
    \raise \size@rect@thick \hbox{%
        \vrule width \size@marg@thick height \size@marg@inner depth 0pt
        \vrule width \size@marg@inner height 0pt depth \size@marg@thick
    }%
    \hss}}

% Vnitřní levý horní roh.
\def\margin@inner@ulft{\hbox to 0pt{\hskip \size@rect@thick
    \vrule width \size@marg@thick height 0pt depth \size@marg@inner
    \vrule width \size@marg@inner height \size@marg@thick depth 0pt
    \hss}}

% Vnitřní pravý dolní roh.
\def\margin@inner@lrt{\hbox to 0pt{\hss
    \raise \size@rect@thick \hbox{%
        \vrule width \size@marg@inner height 0pt depth \size@marg@thick
        \vrule width \size@marg@thick height \size@marg@inner depth 0pt
    }%
    \hskip \size@rect@thick}}

% Vnitřní pravý horní roh.
\def\margin@inner@urt{\hbox to 0pt{\hss
    \vrule width \size@marg@inner height \size@marg@thick depth 0pt
    \vrule width \size@marg@thick height 0pt depth \size@marg@inner
    \hskip \size@rect@thick}}


%%
%% Implementace strojově čitelných prvků - \checkbox
%%
%% Makro vysází jeden checkbox. V jediném argumentu je zadáván tištěný stav
%% chekboxu jako jeden bit: 0 (nezatržený), 1 (zatržený). Pokud je
%% v argumentu něco jiného, pravděpodobně se to celé rozbije.

\def\checkbox#1{%
    \def\bit@sequence{#1}%
    \hbox to \size@rect@length{%
        % okraje vlevo
        \margin@lft
        \margin@llft
        \margin@ulft
        % výplň v závislosti na argumentu
        \bit@test{\rect@h}\hfil
        % okraje vpravo
        \margin@rt
        \margin@lrt
        \margin@urt
    }%
}


%%
%% Implementace strojově čitelných prvků - číslice
%%
%% Každá číslice se skládá ze sedmi obdélníčků, kde obdélníčky 1,3,6,4 a
%% 2,4,7,5 tvoří čtverce se společnou stranou 4.
%%       ---3---
%%       |     |
%%       1     6
%%       |     |
%%       ---4---
%%       |     |
%%       2     7
%%       |     |
%%       ---5---
%% Spodní hrany obdélníčků 2, 5 a 7 jsou zarovnány na baseline. Obdélníčky
%% 1, 3, 4 a 6 je nutné zvednout (\raise). Obdélníček 3 je zvednut o
%% 2\size@rect@shift, obdélníčky 1, 4 a 6 o 1\size@rect@shift

% \digit
% Makro vysází číslici zadanou v argumentu. Pokud je argument prázdný,
% vysází místo pro jednu číslici. Pokud argument obsahuje něco jiného než
% číslici, pravděpodobně se bude chovat jako \relax, ale také se to může
% celé rozbít.
\def\digit#1{%
    % vodící značka pod číslicí
    \lower \size@rect@shift \rect@h
    % tělo číslice
    \csname digit@#1\endcsname
}

% \digit@ - šablona pro číslici
\def\digit@{\digit@ll{0000000}}

% \digit@0..\digit@9 - číslice 0..9
\expandafter\def\csname digit@0\endcsname{\digit@ll{1110111}}
\expandafter\def\csname digit@1\endcsname{\digit@ll{0000011}}
\expandafter\def\csname digit@2\endcsname{\digit@ll{0111110}}
\expandafter\def\csname digit@3\endcsname{\digit@ll{0011111}}
\expandafter\def\csname digit@4\endcsname{\digit@ll{1001011}}
\expandafter\def\csname digit@5\endcsname{\digit@ll{1011101}}
\expandafter\def\csname digit@6\endcsname{\digit@ll{1111101}}
\expandafter\def\csname digit@7\endcsname{\digit@ll{0010011}}
\expandafter\def\csname digit@8\endcsname{\digit@ll{1111111}}
\expandafter\def\csname digit@9\endcsname{\digit@ll{1011111}}

% \digit@ll
% Low-level makro vysází šablonu pro jednu číslici a vyplní v ní obdélníčky
% podle sedmi bitů zadaných v argumentu jako posloupnost 0 a 1. Pokud je
% v argumentu něco jiného než sedm bitů, nejspíš se to celé rozbije.
\def\digit@ll#1{\hbox to \size@rect@length{%
    \def\bit@sequence{#1}%
    % okraje vlevo
    \margin@lft
    \raise \size@rect@shift \margin@lft
    \raise 2\size@rect@shift \margin@lft
    \margin@llft
    \raise 2\size@rect@shift \margin@ulft
    \margin@inner@llft
    \raise \size@rect@shift \margin@inner@ulft
    \raise \size@rect@shift \margin@inner@llft
    \raise 2\size@rect@shift \margin@inner@ulft
    % 7 obdélníčků
    \bit@test{\raise \size@rect@shift \rect@v}%     obdélníček 1
    \bit@test{\rect@v}%                             obdélníček 2
    \bit@test{\raise 2\size@rect@shift \rect@h}%    obdélníček 3
    \bit@test{\raise \size@rect@shift \rect@h}%     obdélníček 4
    \bit@test{\rect@h}%                             obdélníček 5
    \hss
    \bit@test{\raise \size@rect@shift \rect@v}%     obdélníček 6
    \bit@test{\rect@v}%                             obdélníček 7
    \hskip \size@rect@thick
    % okraje vpravo
    \margin@lrt
    \raise 2\size@rect@shift \margin@urt
    \margin@rt
    \raise \size@rect@shift \margin@rt
    \raise 2\size@rect@shift \margin@rt
    \margin@inner@lrt
    \raise \size@rect@shift \margin@inner@urt
    \raise \size@rect@shift \margin@inner@lrt
    \raise 2\size@rect@shift \margin@inner@urt
}}


%%
%% Implementace strojově čitelných prvků - čísla
%%
%% Čísla se skládají z číslic. Definujeme obecná makra \digitsleft
%% a \digitsright pro tisk pole s daným počtem cifer a případně
%% předtištěným číslem zarovnaným vlevo, resp. vpravo. Zbylé volné cifry
%% jsou buď ponechány prázdné, nebo vyplněny libovolnou číslicí. Pokud je
%% zadané číslo delší než počet cifer, vysází se pouze začátek čísla tak,
%% aby byl zachován požadovaný počet cifer.
%%
%% Ostatní (high-level) makra pro tisk polí pro specifická čísla jsou
%% instancí jednoho z těchto dvou maker.

% Počet cifer tištěného pole.
\newcount\dfld@length

% Počet cifer předtištěného čísla.
\newcount\dfld@digits

% Vzorník číslic. Záměrně se používají low-level makra místo makra \digit,
% protože makro \digit sází i vodící značky pod čísla, čímž zbytečně
% zvětšuje výšku vzorníku.
\def\digitsall{%
    \csname digit@\endcsname\kern\size@elem@skip
    \csname digit@0\endcsname\kern\size@elem@skip
    \csname digit@1\endcsname\kern\size@elem@skip
    \csname digit@2\endcsname\kern\size@elem@skip
    \csname digit@3\endcsname\kern\size@elem@skip
    \csname digit@4\endcsname\kern\size@elem@skip
    \csname digit@5\endcsname\kern\size@elem@skip
    \csname digit@6\endcsname\kern\size@elem@skip
    \csname digit@7\endcsname\kern\size@elem@skip
    \csname digit@8\endcsname\kern\size@elem@skip
    \csname digit@9\endcsname
}

% \digitsleft - zarovná číslo vlevo
% #1 - počet cifer
% #2 - číslo, které se má předvyplnit (může být prázdné)
% #3 - číslice pro vyplnění zbylých pozic (může být prázdné)
\def\digitsleft#1#2#3{%
    \edef\arg{#1}%
    \expandafter\dfld@length\arg\relax
    \dfld@digits=0%
    \edef\arg{#2}%
    \expandafter\dfld@count \arg\relax
    \expandafter\dfld@number \arg\relax\relax%
    \dfld@padding{#3}%
}

% \digitsright - zarovná číslo vpravo
% #1 - počet cifer
% #2 - číslo, které se má předvyplnit (může být prázdné)
% #3 - číslice pro vyplnění zbylých pozic (může být prázdné)
\def\digitsright#1#2#3{%
    \edef\arg{#1}%
    \expandafter\dfld@length\arg\relax
    \dfld@digits=0%
    \edef\arg{#2}%
    \expandafter\dfld@count \arg\relax
    \dfld@padding{#3}%
    \expandafter\dfld@number \arg\relax\relax%
}

% Toto makro zvětší hodnotu \dfld@digits o jedna za každý token načítané
% posloupnosti předcházející \relax.
\def\dfld@count#1{%
    \def\loop@test{#1}%
    \ifx\loop@test\loop@relax
        \let\next=\relax
    \else
        \advance\dfld@digits by 1
        \let\next=\dfld@count
    \fi
    \next
}

% Makro vytiskne nejvýše \dfld@length prvních číslic z čísla #1. Za každé
% vytištěné číslo zmenší \dfld@length a \dfld@digits o jedna (musí zůstat
% zachován rozdíl mezi nimi, aby správně pracovalo makro \dfld@padding,
% které je v případě doleva zarovnaného čísla voláno až po \dfld@number).
\def\dfld@number#1{%
    \def\loop@test{#1}%
    \ifx \loop@test\loop@relax
        \let\next=\relax
    \else
        \ifnum\dfld@length=0
            \let\next=\loop@droprelax
        \else
            \advance\dfld@length by -1
            \advance\dfld@digits by -1
            \digit{#1}%
            \ifnum\dfld@length>0\kern\size@elem@skip \fi
            \let\next=\dfld@number
        \fi
    \fi
    \next
}

% Makro tiskne číslici #1, případně prázdnou šablonu pro číslici, dokud
% platí \dfld@length>0 a \dfld@length>\dfld@digits (za každé vytištěné
% políčko snižuje \dfld@length o jedna).
\def\dfld@padding#1{%
    \ifnum \dfld@length=0
        \let\next=\loop@droparg
    \else \ifnum \dfld@length>\dfld@digits
        \advance\dfld@length by -1
        \digit{#1}%
        \ifnum\dfld@length>0\kern\size@elem@skip \fi
        \let\next=\dfld@padding
    \else
        \let\next=\loop@droparg
    \fi\fi
    \next{#1}%
}


%%
%% Podpora pro definice high-level datových číslicových položek
%%

% Vysází předdefinované pole číslic '#2' podle nastavení pro šablonu '#1'.
% Za povinnými prvními dvěma argumenty může následovat nepovinný třetí
% argument udávající předtištěnou hodnotu pole.
\def\digitsfield#1#2{%
    \@ifnextchar[
    {\df@field{#1}{#2}}
    {\df@field{#1}{#2}[]}
}

% Low-level makro implementující \digitsfield.
%   #1 - kód typu formuláře obsahujícího datovou položku
%   #2 - jméno datové položky
%   #3 - hodnota k předvyplnění (může být prázdná)
\def\df@field#1#2[#3]{\hbox to 0pt{\hbox to \textwidth{%
    % horizontální umístění na řádku
    \expandafter \hskip \csname #1@#2@skip\endcsname
    % makro \csname #1@#2@do\endcsname je identické s některým
    % z maker \df@do*
    \csname #1@#2@do\endcsname{#2}{#3}%
    % vyplnění zbytku řádku
    \hfil
}\hss}}

% Sazba číslicové datové položky bez popisky.
%   #1 - jméno datové položky
%   #2 - hodnota k předvyplnění (může být prázdná)
\def\df@do#1#2{%
    \csname dffield@#1\endcsname{#2}%
}

% Sazba číslicové datové položky s popiskou vlevo.
%   #1 - jméno datové položky
%   #2 - hodnota k předvyplnění (může být prázdná)
\def\df@dolft#1#2{%
    \hbox to 0pt{\hss
        \fielddesc@topstyle\strut
        \csname #1name\endcsname%
        \quad
    }%
    \csname dffield@#1\endcsname{#2}%
}

% Sazba číslicové datové položky s popiskou nahoře.
%   #1 - jméno datové položky
%   #2 - hodnota k předvyplnění (může být prázdná)
\def\df@dotop#1#2{\vbox{%
    % sazba datové položky do boxu kvůli zjištění rozměrů
    \setbox0=\hbox{\csname dffield@#1\endcsname{#2}}%
    % vycentrovaný popis nad položkou
    \hbox to \wd0{\hss\fielddesc@topstyle
        \strut \csname #1name\endcsname\hss}%
    \medskip
    % výše vysázená datová položka
    \box0%
}}


%%
%% Specifické typy čísel
%%

% Typ formuláře
% (4 cifry, zarovnáno doprava, vyplněno nulami)
\def\formtypename{Typ formul\'{a}\v{r}e}
\def\dffield@formtype#1{\digitsright{4}{#1}{0}}

% UČO
% (7 cifer, zarovnáno doleva, zbylé místo nevyplňováno)
\def\uconame{u\v{c}o}
\def\dffield@uco#1{\digitsleft{7}{#1}{}}

% Body
% (3 cifry, zarovnáno vpravo, zbylé místo nevyplňováno)
\def\pointsname{body}
\def\dffield@points#1{\digitsright{3}{#1}{}}

% Číslo příkladu
% (2 cifry, zarovnáno vpravo, zbylé místo nevyplňováno)
\def\assgnname{p\v{r}\'{i}klad}
\def\dffield@assgn#1{\digitsright{2}{#1}{}}

% ID zadání generovaného testu
% (4 cifry,zarovnáno doleva, zbylé místo nevyplňováno)
\def\assgnidname{\v{c}\'{i}slo zad\'{a}n\'{i}}
\def\dffield@assgnid#1{\digitsleft{4}{#1}{}}

% Číslo listu
% (2 cifry, zarovnáno vpravo, zbylé místo nevyplňováno)
\def\sheetname{list}
\def\dffield@sheet#1{\digitsright{2}{#1}{}}


%%
%% Implementace strojově čitelných prvků - řádek s číselnými údaji
%%

% Makro vloží #1 na řádek šířky tiskového zrcadla doplněný o boční vodicí
% značky pro rozpoznávání číslic.
\def\digitsline#1{\hbox to \textwidth{%
    \hbox to 0pt{%
        \hss
        \digitsline@sidemarks
        \kern\size@rect@length % \rect@h předstírá, že má šířku 0pt
        \kern\size@sync@skip
    }%
    #1\hfil
    \hbox to 0pt{%
        \kern\size@sync@skip
        \digitsline@sidemarks
        \hss
    }%
}}

% Tisk vodících značek na okrajích řádku s číselnými údaji.
\def\digitsline@sidemarks{%
    \lower \size@rect@shift \rect@h
    \rect@h
    \raise \size@rect@shift \rect@h
    \raise 2\size@rect@shift \rect@h
}


%%
%% Typ formuláře 7: assgnsheet
%% (body za stránku ručně psaných řešení)
%%

% Automatické počítadlo listů.
\newcounter{assgnsheet}

% Typ formuláře - konfigurace pro 'assgnsheet'
\let\as@formtype@do=\df@do
\def\as@formtype@skip{0pt}

% Číslo listu - konfigurace pro 'assgnsheet'
\let\as@sheet@do=\df@dolft
\def\as@sheet@skip{0.3\textwidth}

% UČO - konfigurace pro 'assgnsheet'
\let\as@uco@do=\df@dolft
\def\as@uco@skip{0.5\textwidth}

% Body - konfigurace pro 'assgnsheet'
\let\as@points@do=\df@dolft
\def\as@points@skip{\textwidth\hss}

% \begin{assgnsheet}
% Lze zadat jeden nepovinný argument - číslo příkladu.
\def\assgnsheet{%
    \@ifnextchar[
    {\csname as@assgnsheet\endcsname}
    {\csname as@assgnsheet\endcsname[\relax]}%
}

% Vlastní zahájení prostředí.
\def\as@assgnsheet[#1]{%
    \def\as@arg{#1}%
    % formulář začíná na nové stránce
    \newpage
    % nastavení parametrů stránky
    \hoffset = -1in
    \oddsidemargin = 2.2cm
    \evensidemargin = \oddsidemargin
    \textwidth = 16.6cm
    \voffset = -1in
    \topmargin = 1cm
    \headheight = 0cm
    \headsep = 0cm
    \textheight = \paperheight
    \advance\textheight by -2\topmargin
    \footskip = 0cm
    \hsize=\textwidth
    \@colht\textheight
    \@colroom\textheight \vsize\textheight
    % nastavení LaTeXovské hlavičky a patičky
    \def\@oddfoot{}%
    \def\@evenfoot{}%
    % automatické počítadlo listů - jen když není zadáno číslo explicitně
    \ifx \as@arg\loop@relax
        \stepcounter{assgnsheet}%
        \def\as@arg{\theassgnsheet}%
    \fi
    % povinné vodící značky v záhlaví stránky
    \marks@top
    % konfigurovatelný text před strojově čitelnými údaji
    \as@pretext
    \ifx\as@pretext\empty \vskip \size@rect@shift\fi
    % strojově čitelné údaje
    \digitsline{%
        \digitsfield{as}{formtype}[7]%
        \digitsfield{as}{sheet}[\as@arg]%
        \digitsfield{as}{uco}%
        \digitsfield{as}{points}%
    }%
    % konfigurovatelný text za strojově čitelnými údaji
    \as@posttext
}

% Ukončení prostředí.
\expandafter\def\csname endassgnsheet\endcsname{%
    % ukončení uživatelského obsahu prostředí a odskok na konec stránky
    \par\vfil
    % konfigurovatelný text na konci stránky
    \as@bottomtext
    \vskip -\size@rect@length
    \marks@bottom
    \break
}

% Defaultní text předcházející číslicovým informacím.
\def\as@pretext{}

% Defaultní text následující těsně za číslicovými informacemi.
\def\as@posttext{%
    % sazba vzorníku číslic do boxu pro zjištění šířky a výšky
    \setbox0=\vbox{\hbox{%
            \size@rect@length=0.5\size@rect@length
            \size@rect@thick=0.5\size@rect@thick
            \size@refresh
            \digitsall
        }%
    }%
    % sazba textu do boxu pro zjištění výšky
    \setbox1=\vbox{%
        \hsize=\textwidth
        \advance\hsize by -\wd0
        \advance\hsize by -2\size@rect@length
        \parindent=0pt
        \itshape
        Oblast strojov\v{e} sn\'{i}mateln\'{y}ch informac\'{i}. Sv\'{e} U\v{C}O
        vypl\v{n}te zleva dle p\v{r}i\-lo\v{z}en\'{e}ho vzoru \v{c}\'{i}slic. Jinak do
        t\'{e}to oblasti nezasahujte.\par
    }%
    \medskip
    \hbox to \textwidth{\box1\hfil\box0}
    \medskip
    \hrule height 1pt depth 0pt
}%

% Defaultní text na konci stránky.
\def\as@bottomtext{{%
    \hrule height 1pt depth 0pt
    \medskip
    \hsize=\textwidth
    \parindent=0pt
    \itshape Oblast strojov\v{e} sn\'{i}mateln\'{y}ch informac\'{i},
    nezasahujte. \bfseries \v{R}e\v{s}en\'{i} pi\v{s}te jen na tuto stranu.\par
}}

\endinput

