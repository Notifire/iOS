#!/bin/sh

cert_file="/tmp/$1.pem"

# Download cert
openssl s_client -showcerts -connect $1:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > $cert_file
#echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -text | awk '/-----BEGIN/,/-----END CERTIFICATE-----/{print}' > $cert_file

# Get Public Key
python get_pin_from_certificate.py $cert_file