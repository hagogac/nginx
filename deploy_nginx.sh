#!/usr/bin/env bash
# automation script for installing nginx on localhost + tls certificates on Ubuntu 20.04 VM
# make this script executable with chmod +x ./deploy_nginx.sh
# run wth sudo ./deploy_nginx.sh

# get pre-requisite packages
apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    nginx \

#self-sign a 90-day certificate, max. validity 365 days
openssl req -x509 -nodes -days 90 -newkey rsa:2048 -keyout localhost.key -out localhost.crt -config ssl.conf -extensions 'v3_req' 

#copy cert & key to ssl dirs
cp localhost.crt /etc/ssl/certs/localhost.crt && cp localhost.key /etc/ssl/private/localhost.key

# negotiate perfect forward secrecy with clients - this takes a looong time
openssl dhparam -out /etc/nginx/dhparam.pem 4096

# create a config snippet to point to the ssl key & certificate
touch self-signed.conf
echo $'ssl_certificate /etc/ssl/certs/localhost.crt;\nssl_certificate_key /etc/ssl/private/localhost.key;' > self-signed.conf
cp self-signed.conf /etc/nginx/snippets

# create a config snippet with strong encryption
touch ssl-params.conf
echo $'ssl_protocols TLSv1.3;\nssl_prefer_server_ciphers on;\nssl_dhparam /etc/nginx/dhparam.pem;\nssl_ciphers EECDH+AESGCM:EDH+AESGCM;\nssl_ecdh_curve secp384r1;\nssl_session_timeout  10m;\nssl_session_cache shared:SSL:10m;\nssl_session_tickets off;\nssl_stapling on;\nssl_stapling_verify on; \nresolver 8.8.8.8 8.8.4.4 valid=300s; \nresolver_timeout 5s; \nadd_header X-Frame-Options DENY; \nadd_header X-Content-Type-Options nosniff; \nadd_header X-XSS-Protection "1; mode=block";' > ssl-params.conf
cp ssl-params.conf /etc/nginx/snippets/ssl-params.conf

#backup default nginx config; copy new default; copy new index for localhost
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
\cp default /etc/nginx/sites-available/
\cp index.html /var/www/html/

# restart server
systemctl restart nginx.service
 
# test server
nginx -t

#we should see the output as below; the warning is normal since we self-signed the certificate
#nginx: [warn] "ssl_stapling" ignored, issuer certificate not found for certificate "/etc/ssl/certs/localhost.crt"
#nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#nginx: configuration file /etc/nginx/nginx.conf test is successful
#test with https://localhost. A warning message should come up on the browser that the CA is not trusted. Accept and continue

