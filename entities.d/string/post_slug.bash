#!/bin/bash
#X Function: post_slug
#X Desc    : produce a url-friendly slug string
#X         : string is lowercased, and non-ascii letters replaced with ascii-equivalent
#X         : all non-alnum characters are replaced with string {replstr} (default '-')
#X				 : multiple occurances of {replstr} are reduced to one, and 
#X         : leading and trailing {replstr} chars removed.
#X Synopsis: myslug=$(post_slug "str" ["replstr"])
#X         : replstr is optional, defaults to '-'
#X Example : post_slug 'A title, with  Ŝŧřãņġę  cHaracters ()'
#X         : returns "a-title-with-strange-characters" 
#X         : post_slug ' A title, with  Ŝŧřãņġę  cHaracters ()" '_'
#X         : returns: "a_title_with_strange_characters"
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

#X Function: remove_accents
#X Desc    : Transliterate non-ASCII characters to an ASCII 
#X         : near-equivalent. Uses iconv.
#X Synopsis: remove_accents "string"
remove_accents() {
	echo -n "${1:-}" | iconv -c -f UTF-8 -t ASCII//TRANSLIT//IGNORE
}

#fin
