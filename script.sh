#!/bin/bash
date_2day=`date +"%Y-%m-%d"`
webhook_url=https://hooks.slack.com/services/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

while read -r domain ; do
	echo | openssl s_client -servername $domain -connect $domain:443 | openssl x509 -noout -dates | grep notAfter | awk 'BEGIN { FS = "=" } ; { print $2 }' > date_curl
        while read -r date_curl ; do
                date_cert=`LC_ALL=C date -d "$date_curl" +'%Y-%m-%d'`
                diff=`dateutils.ddiff $date_2day $date_cert`
                if [ $diff -lt 230 ]; then
		curl -X POST --data-urlencode "payload={\"username\": \"ssl-ecker\", \"text\": \"$domain valid till $diff \"}" $webhook_url
                fi
        done < date_curl
done < domains
rm -f date_curl
