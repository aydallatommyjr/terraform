#!/bin/bash
apt-get update
apt-get install nginx -y
echo "It's working !!!!!" >/var/www/html/index.nginx-debian.html