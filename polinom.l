%{
#include <stdio.h>
#include "y.tab.h"

%}
%%

[0-9]+			yylval.ival = atoi(yytext); return NUMBER;
\+				yylval.ival = 1; return SIGN;
\-				yylval.ival = -1; return SIGN;
\*				return MUL;
\^				return POWER;
\(				return OPENBRACKETS;
\)				return CLOSEBRACKETS;
x				return X;
[ \n]+			;

%%