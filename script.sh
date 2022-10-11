#!/bin/bash
set -x					# this line to troublshoot the script can you delete it 
date_2day=`date +"%Y-%m-%d"`		#date of 2day
webhook_url=				# url of webhook

# read line by line from domain file and ignore '#' and blank line
grep -vE '^(\s*$|#)' domains | while read -r domain ; do
	# Use openssl to check the domain, separate the expiration date, and save it in the date_openssl file. 
	echo | openssl s_client -servername $domain -connect $domain:443 | openssl x509 -noout -dates | grep notAfter | awk 'BEGIN { FS = "=" } ; { print $2 }' > date_openssl
	# read the line from file date_openssl
        while read -r date_openssl ; do
		# convert expiration date date to be like as date_2day "%Y-%m-%d"
                date_cert=`LC_ALL=C date -d "$date_openssl" +'%Y-%m-%d'`
		# install package dateutils to make differance between two dates
                diff=`dateutils.ddiff $date_2day $date_cert`
		# if differance date less than 30 will send to slack
                if [ $diff -lt 230 ]; then
		curl -X POST --data-urlencode "payload={\"username\": \"ssl-ecker\", \"text\": \"Domain:$domain \n\t Expire Date: $date_openssl \t valid till: $diff days \"}" $webhook_url
                fi		# end if
        done < date_openssl	# end while
done				# end while
rm -f date_openssl		# delete that file date_openssl
