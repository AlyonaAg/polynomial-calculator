%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
 
extern FILE * yyin;
extern int yyparse();
int yylex();

int mas_coeff[100];

void yyerror(const char *str)
{
        fprintf(stderr,"ERR: %s\n",str);
}
 
int yywrap()
{
	return 1;
} 
  
main(int argc, char* argv[])
{
	printf("\n%s\n", argv[1]);
	yyin = fopen(argv[1], "r");
    yyparse();
} 

%}

%start commands


%union 
{
        long long int mas_mono[2];
		long long int mas_poly[100];
        long long int ival;
}

%token MUL POWER X OPENBRACKETS CLOSEBRACKETS

%token <ival> NUMBER
%token <ival> SIGN

%type <ival> power
%type <ival> coefficient
%type <ival> variable
%type <mas_mono> monomial
%type <mas_poly> polynomial
//%type <mas_poly> expr

%left SIGN
%left MUL
%left UMINUS

%%

commands: command
	| commands command
	;

command:
	result
	;

power:
	POWER NUMBER
	{
		$$ =$2;
	}
	|
	POWER OPENBRACKETS polynomial CLOSEBRACKETS
	{
		$$ = $3[0];
	}
	|
	power power
	{
		long long int result = 1;
		for (int i = 0; i < $2; i++)
			result*=$1;
		$$ = result;
	}
	;

coefficient: 
	NUMBER
	{
		$$ = $1;
	}
	|
	NUMBER power
	{
		if (!$2)
			$$ = 1;
		else
		{
			long long int result = 1;
			for (int i = 0; i < $2; i++)
				result*=$1;
			$$ = result;
		}
	}
	|
	SIGN coefficient %prec UMINUS
	{
		$$ = - $2;
	}
	;

variable:
	X
	{
		$$ = 1;
	}
	|
	X power
	{
		$$ = $2;
	}
	;

monomial:
	coefficient
	{
		$$[0] = 0;
		$$[1] = $1;
	}
	|
	variable
	{
		$$[0] = $1;
		$$[1] = 1;
	}
	|
	coefficient variable
	{
		$$[0] = $2;
		$$[1] = $1;
	}
	;

polynomial:
	monomial
	{
		for (int i =0; i<100; i++)
			$$[i] = 0;
		$$[$1[0]] = $1[1];
	}
	|
	OPENBRACKETS polynomial CLOSEBRACKETS
	{
		for (int i =0; i<100; i++)
			$$[i] = $2[i];
	}
	|
	polynomial SIGN polynomial
	{
		for (int i=0;i<100;i++)
			$$[i]=$1[i]+$2*$3[i];
	}
	|
	polynomial MUL polynomial
	{
		for (int i=0;i<100;i++)
			$$[i]=0;
		for (int i=0;i<100;i++)
			for (int j=0; j<100; j++)
				if($1[i] && $3[j])
					  $$[i+j] += $1[i]*$3[j];
	}
	|
	polynomial power
	{
		if (!$2)
		{
			for (int i=0;i<100;i++)
				$$[i] = 0;
			$$[0] = 1;
		}
		else
		{
			long long int temp_mas[100];

			for (int i = 0 ; i < 100 ; i++)
			{
				temp_mas[i] = 0;
				$$[i] = $1[i];
			}

			for (int k = 0; k < $2-1; k++)
			{
				for (int i=0;i<100;i++)
					for (int j=0; j<100; j++)
						if($1[i] && $$[j])
							  temp_mas[i+j] += $1[i]*$$[j];

				for (int i=0;i<100;i++)
				{
					$$[i] = temp_mas[i];
					temp_mas[i] = 0;
				}
			}

		}
	}
	|
	SIGN polynomial %prec UMINUS
	{
		for (int i = 0; i < 100; i++)
			$$[i]=(-1)*$2[i];
	}
	;

result:
	polynomial
	{
		int flag = 0;
		for (int i = 99; i>=0; i--)
		{
			if ($1[i])
			{
				if ($1[i] > 0 && flag)
					printf("+");
				
				if (($1[i] != 1 && $1[i] != -1) || i == 0)
					printf("%lld", $1[i]);
				if ($1[i] == -1 && i != 0)
					printf("-");

				if (i > 1)
					printf("x^%d", i);
				if (i == 1)
					printf("x");

				flag = 1;
			}
		}
		printf("\n");
	}
	;