#!/bin/bash
NGINX_VHOSTS=${NGINX_VHOSTS:-/data/vhosts}
NGINX_CONF=${NGINX_CONF}

rm /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
cp $NGINX_VHOSTS /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/

#iterate though all the env vars and replace %ENV% with the value
printenv | while read envdef; do #iterate over all env vars
    key=${envdef%=*} # extract the env key name

    # replace all instances of %KEY% with the relevant environment value
    sed -i "s|%$key%|${!key}|" /etc/nginx/sites-available/*.conf
    sed -i "s|%$key%|${!key}|" /etc/nginx/nginx.conf # replace all instances of %KEY% with the value
    sed -i "s|%$key%|${!key}|" /etc/nginx/nginx.conf # replace all instances of %KEY% with the value

    # also do replacedments in addtional conf dir if it exists
    if [ -d "$NGINX_CONF" ]; then
        sed -i "s|%$key%|${!key}|" ${NGINX_CONF}/*.conf
    fi
done


# dynamic ip restriction. Will create a file name ip-restriction.conf in your NGINX_CONF directory
# include this file within your vhosts as required.
# use the NGINX_ALLOWED_IPS env to pass in a list of allowed ip addresses in the format: 1.1.1.1;2.2.2.2;3.3.3.3; etc

IP_CONF=${NGINX_CONF}/ip-restriction.conf
ALLOWED_IPS=${NGINX_ALLOWED_IPS}
if [ $ALLOWED_IPS:?  ]; then

    echo "satisfy any;" > $IP_CONF
    echo "error_page 403 = @deny;" >> $IP_CONF


    ips=$(echo $ALLOWED_IPS | tr ";" "\n")
    for ip in $ips
    do
        echo "allow $ip;" >> $IP_CONF
    done

    echo "deny all;" >> $IP_CONF
fi

cat /etc/nginx/sites-available/*.conf

exec /usr/sbin/nginx
