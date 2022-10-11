#!/bin/bash
set -x					#to troublshoot the scriipt can you # it 
date_2day=`date +"%Y-%m-%d"`		#date of 2day
webhook_url=				# url of webhook

# read line by line from domain file and ignore # and blank line
grep -vE '^(\s*$|#)' domains | while read -r domain ; do
	#[[ "$domain" =~ ^#.*$ ]] && continue
	# use openssl to verify domain and split date of expire and save that date in file date_openssl
	echo | openssl s_client -servername $domain -connect $domain:443 | openssl x509 -noout -dates | grep notAfter | awk 'BEGIN { FS = "=" } ; { print $2 }' > date_openssl
	# read line from file date_openssl
        while read -r date_openssl ; do
		# convert expire date to be like as date_2day "%Y-%m-%d"
                date_cert=`LC_ALL=C date -d "$date_openssl" +'%Y-%m-%d'`
		# install package dateutils to make differance between two dates
                diff=`dateutils.ddiff $date_2day $date_cert`
		# if differance less than 30 will send to slack
                if [ $diff -lt 230 ]; then
		curl -X POST --data-urlencode "payload={\"username\": \"ssl-ecker\", \"text\": \"Domain:$domain \n\t Expire Date: $date_openssl \t valid till: $diff days \"}" $webhook_url
                fi		# end if
        done < date_openssl	# end while
done				# end while
rm -f date_openssl			# delete that file date_openssl
