# Local nginx delpoyment

Scope: 

This is an automation script that installs and configures a local deployment of the nginx web server along with generating a self-signed TLS
certificate. The local nginx service will be available on both ports 80 and 443. 

## Prerequisites

Ubuntu 20.04   
bash (v.5 and up would be nice) \
openssl \
ufw \
nginx

Check the version of bash with:

```bash
apt info bash
```
Check if ufw is installed. 

```bash
which ufw
```
Check if the firewall is active. If not, enable the firewall on boot:
```bash
sudo ufw status
sudo ufw enable
```

## Usage

Make the script executable. Run

```bash
chmod +x ./deploy_nginx.sh
sudo ./deploy_nginx.sh
```
## Testing

Allow nginx on the local firewall

```bash
sudo ufw allow 'Nginx Full'
````

Restart the ngninx service

```bash
systemctl restart nginx.service
```

Test the new nginx config

```bash
nginx -t
```

We should see the output as below; the warning is normal since we self-signed the certificate

```bash
nginx: [warn] "ssl_stapling" ignored, issuer certificate not found for certificate "/etc/ssl/certs/localhost.crt"
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Test with https://<local_IP_of_the_server> 
A warning message should come up on the browser that the CA is not trusted. Accept and continue.


## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[GPL](https://choosealicense.com/licenses/gpl-3.0/)
