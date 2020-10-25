#!/bin/bash
#X Function: post_slug
#X Desc    : Produce a URL-friendly slug string.
#X         : String is lowercased, and non-ASCII chars replaced with 
#X         : ASCII-equivalent.
#X         : All non-alnum chars are replaced with {replacestr} (default '-')
#X				 : Multiple occurances of {replacestr} are reduced to one, and 
#X         : leading and trailing {replacestr} chars removed.
#X         :
#X Synopsis: myslug=$(post_slug "str" ["replacestr"])
#X         :   replstr   is optional, defaults to '-'
#X         :
#X Example : post_slug 'A title, with  Ŝŧřãņġę  cHaracters ()'
#X         : # ^ returns "a-title-with-strange-characters" 
#X         : post_slug ' A title, with  Ŝŧřãņġę  cHaracters ()" '_'
#X         : # ^ returns: "a_title_with_strange_characters"
#X Depends : iconv
shopt -s extglob
post_slug() {
	local str="${1:-}" repl="${2:--}" preserve_case="${3:-0}"
	# lowercase all
	if ((preserve_case)); then
		str="$(echo "${str}"   | iconv -f UTF-8 -t ASCII//TRANSLIT )"
	else 
		str="$(echo "${str,,}" | iconv -f UTF-8 -t ASCII//TRANSLIT )"
	fi
	# replace all non alnum chars with {repl}
	str="${str//[^[:alnum:]]/${repl}}"
  # replace all double occurences of {repl} with one only {repl}
	str="${str//+([${repl}])/${repl}}"
	# remove beginning {repl} char
	[[ ${str:0:1} == "$repl" ]] && str="${str:1}"
	# remove ending {repl} char
	[[ ${str: -1} == "$repl" ]] && str="${str:0: -1}"
	# translate non ascii chars
	echo -n "$str"
}
declare -fx post_slug

#X Function: remove_accents
#X Desc    : Transliterate non-ASCII characters to an ASCII 
#X         : near-equivalent. Uses iconv.
#X Synopsis: remove_accents "string"
remove_accents() {
	echo -n "${1:-}" | iconv -c -f UTF-8 -t ASCII//TRANSLIT//IGNORE
}
declare -fx remove_accents
#fin
