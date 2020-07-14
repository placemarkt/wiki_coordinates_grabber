#!/usr/bin/env fish

# This file must be sourced in fish:
#
#   . (which env_parallel.fish)
#
# after which 'env_parallel' works
#
#
# Copyright (C) 2016-2020 Ole Tange, http://ole.tange.dk and Free
# Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>
# or write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301 USA

# If you are a fisherman feel free to improve the code
#
# The code needs to deal with variables like:
#   set funky (perl -e 'print pack "c*", 2..254')
#
# Problem:
#   Tell the difference between:
#     set tmp "a'  'b'  'c"
#     set tmparr1 "a'  'b"  'c'
#     set tmparr2 'a'  "b'  'c"
#   The output from `set` is exactly the same.
# Solution:
#   for-loop for each variable. Each value is separated with a
#   separator.

function env_parallel
  # env_parallel.fish

  # --session
  perl -e 'exit grep { /^--session/ } @ARGV' -- $argv; or begin;
    setenv PARALLEL_IGNORED_NAMES (
        begin;
	  functions -n
	  set -n;
	end | perl -pe 's/\n/,/g';
    )
    return 0
  end;
  setenv PARALLEL_ENV (
    begin;
      set _grep_REGEXP (
        begin;
          perl -e '
	    for(@ARGV){
                /^_$/ and $next_is_env = 0;
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env = /^--env$/;
            }
            $vars = join "|",map { quotemeta $_ } @envvar;
            print $vars ? "($vars)" : "(.*)";
            ' -- $argv;
        end;
      )
      # Deal with --env _
      set _ignore_UNDERSCORE (
        begin;
          perl -e '
            for(@ARGV){
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env=/^--env$/;
            }
            if(grep { /^_$/ } @envvar) {
                if(not open(IN, "<", "$ENV{HOME}/.parallel/ignored_vars")) {
             	    print STDERR "parallel: Error: ",
            	    "Run \"parallel --record-env\" in a clean environment first.\n";
                } else {
            	    chomp(@ignored_vars = <IN>);
                }
            }
            if($ENV{PARALLEL_IGNORED_NAMES}) {
                push @ignored_vars, split/,/, $ENV{PARALLEL_IGNORED_NAMES};
                chomp @ignored_vars;
            }
            $vars = join "|",map { quotemeta $_ } @ignored_vars;
	    print $vars ? "($vars)" : "(,,nO,,VaRs,,)";
            ' -- $argv;
        end;
      )

      # --record-env
      perl -e 'exit grep { /^--record-env$/ } @ARGV' -- $argv; or begin;
        begin;
	  functions -n | perl -pe 's/,/\n/g';
	  set -n;
	end | cat > $HOME/.parallel/ignored_vars;
      end;

      # Export function definitions
      # Keep the ones from --env
      # Ignore the ones from ~/.parallel/ignored_vars
      # Dump each function defition
      # Replace \001 with \002 because \001 is used by env_parallel
      # Convert \n to \001
      functions -n | perl -pe 's/,/\n/g' | \
        grep -Ev '^(PARALLEL_ENV|PARALLEL_TMP)$' | \
        grep -E "^$_grep_REGEXP"\$ | grep -vE "^$_ignore_UNDERSCORE"\$ | \
        while read d; functions $d; end | \
        perl -pe 's/\001/\002/g and not $printed++ and print STDERR
          "env_parallel: Warning: ASCII value 1 in functions is not supported\n";
                  s/\n/\001/g';
      # Convert scalar vars to fish \XX quoting
      # Keep the ones from --env
      # Ignore the ones from ~/.parallel/ignored_vars
      # Ignore read only vars
      # Execute 'set' of the content
      eval (set -L | \
        grep -Ev '^(PARALLEL_TMP)$' | \
        grep -E "^$_grep_REGEXP " | grep -vE "^$_ignore_UNDERSCORE " | \
        perl -ne 'chomp;
          ($name,$val)=split(/ /,$_,2);
          $name=~/^(HOME|USER|COLUMNS|FISH_VERSION|LINES|PWD|SHLVL|_|
                    history|status|version)$|\./x and next;
          if($val=~/^'"'"'/) { next; }
          print "set $name \"\$$name\";\n";
        ')
      # Generate commands to set scalar variables
      # Keep the ones from --env
      # Ignore the ones from ~/.parallel/ignored_vars
      #
      begin;
        for v in (set -n | \
          grep -Ev '^(PARALLEL_TMP)$' | \
          grep -E "^$_grep_REGEXP\$" | grep -vE "^$_ignore_UNDERSCORE\$");
          # Separate variables with the string: \000
	  # array_name1 val1\0
	  # array_name1 val2\0
	  # array_name2 val3\0
	  # array_name2 val4\0
          eval "for i in \$$v;
            echo -n $v \$i;
    	    perl -e print\\\"\\\\0\\\";
          end;"
        end;
        # A final line to flush the last variable in Perl
        perl -e print\"\\0\";
      end | perl -0 -ne '
        # Remove separator string \0
        chop;
	# Split line into name and value
        ($name,$val)=split(/ /,$_,2);
        # Ignore read-only vars
        $name=~/^(HOME|USER|COLUMNS|FISH_VERSION|LINES|PWD|SHLVL|_|
                  fish_pid|history|hostname|status|version)$/x and next;
        # Single quote $val
	if($val =~ /[^-_.+a-z0-9\/]/i) {
	  $val =~ s/\047/\047"\047"\047/g;  # "-quote single quotes
  	  $val = "\047$val\047";            # single-quote entire string
	  $val =~ s/^\047\047|\047\047$//g; # Remove unneeded '' at ends
	} elsif ($val eq "") {
	  $val = "\047\047";
	}

        if($name ne $last and $last) {
          # The $name is different, so this is a new variable.
          # Print the last one.
          # Separate list elements by 2 spaces
          $"="  ";
          print "set $last @qval;\n";
          @qval=();
        }
        push @qval,$val;
        $last=$name;
        '| \
        perl -pe 's/\001/\002/g and not $printed++ and print STDERR
          "env_parallel: Warning: ASCII value 1 in variables is not supported\n";
          s/\n/\001/g'
    end;
    )
  # If --record-env: exit
  perl -e 'exit grep { /^--record-env$/ } @ARGV' -- $argv; and parallel $argv;
  set _parallel_exit_CODE $status
  set -e PARALLEL_ENV
  return $_parallel_exit_CODE
end
