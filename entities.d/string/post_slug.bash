#!/bin/bash
#X Function: post_slug
#X Desc    : produce a url-friendly slug string
#X         : string is lowercased, and non-ascii letters replaced with ascii-equivalent
#X         : all non-alnum characters are replaced with string {replstr} (default '_')
#X				 : multiple occurances of {replstr} are reduced to one, and 
#X         : leading and trailing {replstr} chars removed.
#X Synopsis: {newstr}=$(post_slug {str} [{replstr}])
#X         : {replstr} is optional, defaults to _
#X Example : post_slug '\nA title, with  sTrange  cHaracters like *&#^"@:'
#X         : returns "a-title-with-strange-characters-like" 
#X Example : post_slug ' A title, with  sTrange  cHaracters like *&#^@: Å Æ Ç È É Ê Ë "
#X         : a_title_with_strange_characters_like_a_ae_c_e_e_e_e

shopt -s extglob

post_slug() {
	local str="${1:-}" repl="${2:-_}"
	# lowercase all
	str="$(echo "${str,,}" | iconv -f UTF-8 -t ASCII//TRANSLIT )"
	# replace all non alnum chars with {repl}
	str="${str//[^[:alnum:]]/${repl}}"
  # replace all double occurences of {repl} with one only {repl}
	str="${str//+([${repl}])/${repl}}"
	# remove beginning {repl} char
	[[ ${str:0:1} == $repl ]] && str="${str:1}"
	# remove ending {repl} char
	[[ ${str: -1} == $repl ]] && str="${str:0: -1}"
	# translate non ascii chars
	echo -n "$str"
}

#X Function: remove_accents
#X Synopsis; {str}=$(remove_accents {rawstr})
remove_accents() {
	echo -n "${1:-}" | iconv -f UTF-8 -t ASCII//TRANSLIT
}

#fin
