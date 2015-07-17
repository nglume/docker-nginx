FROM spira/docker-base

MAINTAINER "Zak Henry" <zak.henry@gmail.com>

WORKDIR /tmp

# Install Nginx
RUN apt-get update -y && \
    apt-get install -y nginx

# Apply Nginx configuration
ADD config/nginx.conf /opt/etc/nginx.conf
RUN rm /etc/nginx/sites-enabled/default

#Declaring the data dir
ENV data_root /data

# Nginx startup script
ADD config/nginx-start.sh /opt/bin/nginx-start.sh
RUN chmod u=rwx /opt/bin/nginx-start.sh

RUN mkdir -p ${data_root}
#VOLUME ["/data"]
VOLUME ${data_root}

# PORTS
EXPOSE 80 8080 443

WORKDIR /opt/bin
ENTRYPOINT ["/opt/bin/nginx-start.sh"]
