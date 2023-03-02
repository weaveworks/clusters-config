while true
do
    curl -s -o /dev/null -w "%{http_code}" 'https://wge-2448.eng-sandbox.weave.works/v1/objects?kind=HelmRelease' \
      -H 'Accept: */*' \
      -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
      -H 'Connection: keep-alive' \
      -H 'Referer: https://wge-2448.eng-sandbox.weave.works/applications' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36' \
      -H 'sec-ch-ua: "Not?A_Brand";v="8", "Chromium";v="108", "Google Chrome";v="108"' \
      -H 'sec-ch-ua-mobile: ?0' \
      -H 'sec-ch-ua-platform: "macOS"' \
      --compressed
    sleep 5
done
