%{
/*
 * Copyright (c) 20001 Stephen Williams (steve@icarus.com)
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */
#if !defined(WINNT) && !defined(macintosh)
#ident "$Id: cfparse.y,v 1.3 2001/11/13 03:30:26 steve Exp $"
#endif


# include  "globals.h"

%}

%union {
      char*text;
};

%token TOK_Da TOK_Dv TOK_Dy
%token TOK_DEFINE TOK_INCDIR
%token <text> TOK_PLUSARG TOK_PLUSWORD TOK_STRING

%%

start
	:
	| item_list
	;

item_list
	: item_list item
	| item
	;

item
  /* Absent any other matching, a token string is taken to be the name
     of a source file. Add the file to the file list. */

	: TOK_STRING
		{ process_file_name($1);
		  free($1);
		}

  /* The -a flag is completely ignored. */

        | TOK_Da { }

  /* The -v <libfile> flag is ignored, and the <libfile> is processed
     as an ordinary source file. */

        | TOK_Dv TOK_STRING
		{ process_file_name($2);
		  fprintf(stderr, "%s:%u: Ignoring -v in front of %s\n",
			  @1.text, @1.first_line, $2);
		  free($2);
		}

  /* This rule matches "-y <path>" sequences. This does the same thing
     as -y on the command line, so add the path to the library
     directory list. */

        | TOK_Dy TOK_STRING
		{ process_library_switch($2);
		  free($2);
		}

	| TOK_DEFINE TOK_PLUSARG
		{ process_define($2);
		  free($2);
		}

  /* The +incdir token introduces a list of +<path> arguments that are
     the include directories to search. */

	| TOK_INCDIR inc_args

  /* The +<word> tokens that are not otherwise matched, are
     ignored. The skip_args rule arranges for all the argument words
     to be consumed. */

	| TOK_PLUSWORD skip_args
		{ fprintf(stderr, "%s:%u: Ignoring %s\n",
			  @1.text, @1.first_line, $1);
		  free($1);
		}
	| TOK_PLUSWORD
		{ fprintf(stderr, "%s:%u: Ignoring %s\n",
			  @1.text, @1.first_line, $1);
		  free($1);
		}
	;

  /* inc_args are +incdir+ arguments in order. */
inc_args
	: inc_args inc_arg
	| inc_arg
	;

inc_arg : TOK_PLUSARG
		{ process_include_dir($1);
		  free($1);
		}
	;

  /* skip_args are arguments to a +word flag that is not otherwise
     parsed. This rule matches them and releases the strings, so that
     they can be safely ignored. */
skip_args
	: skip_args skip_arg
	| skip_arg
	;

skip_arg : TOK_PLUSARG
		{ free($1);
		}
	;

%%

int yyerror(const char*msg)
{
}
