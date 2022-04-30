#!/bin/bash

web1=$(sudo lxc list contenedor1 -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
web2=$(sudo lxc list contenedor2 -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
web3=$(sudo lxc list contenedor3 -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')
#web4=$(sudo lxc list contenedor4 -c 4 | awk '!/IPV4/{ if ( $2 != "" ) print $2}')

error404='HTTP/1.1 404 Not Found
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>HTTP 404 Error</title>
    </head>
    <body>
        <main>
            <h1>HTTP 404 Error</h1>

            Esta es mi vista personalizada del error 404 - Página o recurso no encontrado
        </main>
    </body>
</html>'

error503='HTTP/1.1 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>HTTP 503 Error</title>
    </head>
    <body>
        <main>
            <h1>HTTP 503 Error</h1>

            Esta es mi vista personalizada del error 503 - Servicio No Disponible
        </main>
    </body>
</html>'

haproxy="global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# Default ciphers to use on SSL-enabled listening sockets.
	# For more information, see ciphers(1SSL). This list is from:
	#  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
	# An alternative list with additional directives can be obtained from
	#  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
	ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
	ssl-default-bind-options no-sslv3

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 404 /etc/haproxy/errors/404.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http


backend web-backend
   balance roundrobin
   stats enable
   stats auth admin:admin
   stats uri /haproxy?stats

   server contenedor1 "$web1":80 check
   server contenedor2 "$web2":80 check
   server contenedor3 "$web3":80 check backup

frontend http
  bind *:80
  default_backend web-backend"

sudo lxc exec haproxy -- sh -c "echo '' > /etc/haproxy/errors/404.http"
sleep 10
sudo lxc exec haproxy -- sh -c "echo '$error404' > /etc/haproxy/errors/404.http"
sleep 10

sudo lxc exec haproxy -- sh -c "echo '' > /etc/haproxy/errors/503.http"
sleep 10
sudo lxc exec haproxy -- sh -c "echo '$error503' > /etc/haproxy/errors/503.http"
sleep 10

sudo lxc exec haproxy -- sh -c "echo '' > /etc/haproxy/haproxy.cfg"
sleep 10
sudo lxc exec haproxy -- sh -c "echo '$haproxy' > /etc/haproxy/haproxy.cfg"
sleep 10

sudo lxc exec haproxy -- sudo systemctl start haproxy
sleep 10

sudo lxc config device add haproxy http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
sleep 10

sudo lxc exec haproxy -- sudo service haproxy reload
sleep 10

#https://www.haproxy.com/blog/serve-dynamic-custom-error-pages-with-haproxy/