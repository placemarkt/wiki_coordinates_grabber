#!/usr/bin/env tcsh

# This file must be sourced in tcsh:
#
#   source `which env_parallel.tcsh`
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

set _parallel_exit_CODE=0
if ("`alias env_parallel`" == '' || ! $?PARALLEL_CSH) then
  # Activate alias
  alias env_parallel '(setenv PARALLEL_CSH "\!*"; source `which env_parallel.csh`)'
else
  # Get the --env variables if set
  # --env _ should be ignored
  # and convert  a b c  to (a|b|c)
  # If --env not set: Match everything (.*)

  # simple 'tempfile': Return nonexisting filename: /tmp/parXXXXX
  alias _tempfile 'perl -e do\{\$t\=\"/tmp/par\".join\"\",map\{\(0..9,\"a\"..\"z\",\"A\"..\"Z\"\)\[rand\(62\)\]\}\(1..5\)\;\}while\(-e\$t\)\;print\"\$t\\n\"'
  set _tMpscRIpt=`_tempfile`

  cat <<'EOF' > $_tMpscRIpt
            #!/usr/bin/perl

            for(@ARGV){
                /^_$/ and $next_is_env = 0;
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env = /^--env$/;
            }
            $vars = join "|",map { quotemeta $_ } @envvar;
            print $vars ? "($vars)" : "(.*)";
'EOF'
  set _grep_REGEXP="`perl $_tMpscRIpt -- $PARALLEL_CSH`"

  # Deal with --env _
  cat <<'EOF' > $_tMpscRIpt
            #!/usr/bin/perl

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
            	    $vars = join "|",map { quotemeta $_ } @ignored_vars;
		    print $vars ? "($vars)" : "(,,nO,,VaRs,,)";
                }
            }
'EOF'
  set _ignore_UNDERSCORE="`perl $_tMpscRIpt -- $PARALLEL_CSH`"
  rm $_tMpscRIpt

  # Get the scalar and array variable names
  set _vARnAmES=(`set | perl -ne 's/\s.*//; /^(#|_|killring|prompt2|command|PARALLEL_ENV|PARALLEL_TMP)$/ and next; /^'"$_grep_REGEXP"'$/ or next; /^'"$_ignore_UNDERSCORE"'$/ and next; print'`)

  # Make a tmpfile for the variable definitions
  set _tMpvARfILe=`_tempfile`
  touch $_tMpvARfILe
  # Make a tmpfile for the variable definitions + alias
  set _tMpaLLfILe=`_tempfile`
  foreach _vARnAmE ($_vARnAmES);
    # These 3 lines break in csh version 20110502-3
    # if not defined: next
    eval if'(! $?'$_vARnAmE') continue'
    # if $#myvar <= 1 echo scalar_myvar=$var
    eval if'(${#'$_vARnAmE'} <= 1) echo scalar_'$_vARnAmE'='\"\$$_vARnAmE\" >> $_tMpvARfILe;
    # if $#myvar > 1 echo array_myvar=$var
    eval if'(${#'$_vARnAmE'} > 1) echo array_'$_vARnAmE'="$'$_vARnAmE'"' >> $_tMpvARfILe;
  end
  unset _vARnAmE _vARnAmES
  # shell quote variables (--plain needed due to ignore if $PARALLEL is set)
  # Convert 'scalar_myvar=...' to 'set myvar=...'
  # Convert 'array_myvar=...' to 'set array=(...)'
  cat $_tMpvARfILe | parallel --plain --shellquote |  perl -pe 's/^scalar_(\S+).=/set $1=/ or s/^array_(\S+).=(.*)/set $1=($2)/ && s/\\ / /g;' > $_tMpaLLfILe
  # Cleanup
  rm $_tMpvARfILe; unset _tMpvARfILe

# ALIAS TO EXPORT ALIASES:

#   Quote ' by putting it inside "
#   s/'/'"'"'/g;
#   ' => \047 " => \042
#   s/\047/\047\042\047\042\047/g;
#   Quoted: s/\\047/\\047\\042\\047\\042\\047/g\;

#   Remove () from second column
#   s/^(\S+)(\s+)\((.*)\)/\1\2\3/;
#   Quoted: s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;

#   Add ' around second column
#   s/^(\S+)(\s+)(.*)/\1\2'\3'/
#   \047 => '
#   s/^(\S+)(\s+)(.*)/\1\2\047\3\047/;
#   Quoted: s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;

#   Quote ! as \!
#   s/\!/\\\!/g;
#   Quoted: s/\\\!/\\\\\\\!/g;

#   Prepend with "\nalias "
#   s/^/\001alias /;
#   Quoted: s/\^/\\001alias\ /\;
  alias | \
    perl -ne '/^'"$_grep_REGEXP"'/ or next; /^'"$_ignore_UNDERSCORE"'[^_a-zA-Z]/ and next; print' | \
    perl -pe s/\\047/\\047\\042\\047\\042\\047/g\;s/\^\(\\S+\)\(\\s+\)\\\(\(.\*\)\\\)/\\1\\2\\3/\;s/\^\(\\S+\)\(\\s+\)\(.\*\)/\\1\\2\\047\\3\\047/\;s/\^/\\001alias\ /\;s/\\\!/\\\\\\\!/g >> $_tMpaLLfILe

  setenv PARALLEL_ENV "`cat $_tMpaLLfILe; rm $_tMpaLLfILe`";
  unset _tMpaLLfILe;
  # Use $PARALLEL_CSH set in calling alias
  parallel
  set _parallel_exit_CODE=$status
  setenv PARALLEL_ENV
  setenv PARALLEL_CSH
endif
(exit $_parallel_exit_CODE)
