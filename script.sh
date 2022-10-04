#!/bin/bash
set -x
date_2day=`date +"%Y-%m-%d"`
#webhook_url=https://hooks.slack.com/services/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
webhook_url=

grep -vE '^(\s*$|#)' domains | while read -r domain ; do
	[[ "$domain" =~ ^#.*$ ]] && continue
	echo | openssl s_client -servername $domain -connect $domain:443 | openssl x509 -noout -dates | grep notAfter | awk 'BEGIN { FS = "=" } ; { print $2 }' > date_curl
        while read -r date_curl ; do
                date_cert=`LC_ALL=C date -d "$date_curl" +'%Y-%m-%d'`
                diff=`dateutils.ddiff $date_2day $date_cert`
                if [ $diff -lt 230 ]; then
		curl -X POST --data-urlencode "payload={\"username\": \"ssl-ecker\", \"text\": \"Domain:$domain \n\t Expire Date: $date_cert \t valid till: $diff days \"}" $webhook_url
                fi
        done < date_curl
done
#done < domains
rm -f date_curl
