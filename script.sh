#!/bin/bash
date_2day=`date +"%Y-%m-%d"`
webhook_url=

while read -r domain ; do
	echo | openssl s_client -servername $domain -connect $domain:443 | openssl x509 -noout -dates | grep notAfter | awk 'BEGIN { FS = "=" } ; { print $2 }' > date_curl
        while read -r date_curl ; do
                date_cert=`LC_ALL=C date -d "$date_curl" +'%Y-%m-%d'`
                diff=`dateutils.ddiff $date_2day $date_cert`
                if [ $diff -lt 30 ]; then
                curl -X POST --data-urlencode "payload={\"channel\": \"#certificates\", \"username\": \"ssl-checker\", \"text\": \"the domain $domain validate untill $diff \"}" $webhook_url
                fi
        done < date_curl
done < domains
rm -f date_curl
