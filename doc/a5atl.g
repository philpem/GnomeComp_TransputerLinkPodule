. GCAL  standard macros - Adobe Type Library (PostScript) A5 Version
. Last updated by PH on 15/10/87
.
.unless ~%fancy
.fancy "a5atl"
.fi
.unless set maintypesize
.set maintypesize 10
.fi
.library "a4atl"
.set style "a5atl"
.pagelength 523.0
.linelength 330.0
.margin 345.0
.emphasize 338.0 '|'
.nem
.foot
$c ~%page
.endf
$.footnote
.linelength 330.0
.endf
.request "POSTSCRIPT:FORMAT=A5"
.request "BBCVDU:MARGIN 5"
.pageoffset -26.0 0-18.0
.resetlinenumber 0
