#!/bin/bash
#X Function: urlpayload_encode payload_encode payload_decode

urlpayload_encode() {	
	echo -n "$( urlencode "$(payload_encode "${1}")" )" 
	return 0
}
payload_encode() { 
	echo -n "$( echo -n "${1:-}" | gzip 2>/dev/null | base64 -w0 2>/dev/null)" 
	return 0
}
payload_decode() {
	local str="${1}" bstr='' gzipid="$(echo -e "\x1f\x8b")" 
	[[ -z "$str" ]] && { echo -n ''; return 0; }
	# is base64?
  bstr="$(echo "$str" | base64 -d -i 2> /dev/null | tr -d '\r\n\0')"
  if ((! ${#bstr})); then
		echo -n "$str"
		return 0
	fi
	# is gzip?
	if [[ "${bstr:0:2}" == "$gzipid" ]]; then
#		echo -n "$( echo "${str}" | base64 -d  2> /dev/null | /bin/gzip -d  2>/dev/null)"
#		echo -n "$( echo "${str}" | base64 -d  2>/dev/null | tr -d '\r\n\0' | /bin/gzip -d  2>/dev/null)"
#		echo -n "$( echo "${str}" | base64 -d | tr -d '\r\n\0' | /bin/gzip -d)"
		echo -n "$( echo -n "${str}" | base64 -d | gzip -d)"
#		echo -n "$( echo "${bstr}" | /bin/gzip -d  2>/dev/null)"
	else
		echo -n "${bstr}"
	fi
	unset str bstr
	return 0
}
#fin
