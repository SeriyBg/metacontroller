#!/bin/bash
#
# This is a rather minimal example Argbash potential
# Example taken from http://argbash.readthedocs.io/en/stable/example.html
#
# ARG_OPTIONAL_SINGLE([ignore],[i],[ignore directories])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.9.0 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info
#
#
# Generated online by https://argbash.io/generate
# This script runs the smoke tests that check basic Metacontroller functionality
# by running through each example controller.
#
# * You should only run this in a test cluster.
# * You should already have Metacontroller installed in your test cluster.
# * You should have kubectl in your PATH and configured for the right cluster.

die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='i'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_ignore=


print_help()
{
	printf 'Usage: %s [-i|--ignore <arg>]\n' "$0"
	printf '\t%s\n' "-i, --ignore: ignore directories (no default)"
}


parse_commandline()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-i|--ignore)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_ignore="$2"
				shift
				;;
			--ignore=*)
				_arg_ignore="${_key##--ignore=}"
				;;
			-i*)
				_arg_ignore="${_key##-i}"
				;;
			*)
				_PRINT_HELP=yes die "FATAL ERROR: Got an unexpected argument '$1'" 1
				;;
		esac
		shift
	done
}

parse_commandline "$@"

set -e

logfile=$(mktemp)
echo "Logging test output to ${logfile}"

ignore_dirs=( "${_arg_ignore[@]/%/\/test.sh}" )

echo "Ignored directories: ${ignore_dirs}"

cleanup() {
  rm "${logfile}"
}
trap cleanup EXIT

for test in */test.sh; do
  if [[ "${ignore_dirs[@]}" =~ ${test} ]]; then
    echo "Skipping ${test}"
    continue
  fi
  echo -n "Running ${test}..."
  if ! (cd "$(dirname "${test}")" && ./test.sh > "${logfile}" 2>&1); then
    echo "FAILED"
    cat "${logfile}"
    echo "Test ${test} failed!"
    exit 1
  fi
  echo "PASSED"
done
