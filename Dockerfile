FROM ubuntu

WORKDIR /tmp/nginx-installation
RUN apt-get update -y

ENV nginx_version 1.6.2
RUN wget http://nginx.org/download/nginx-$nginx_version.tar.gz && \
    tar -xzvf nginx-$nginx_version.tar.gz && \
    rm -f ./nginx-$nginx_version.tar.gz

ENV nginx_cache_purge_version 2.3
RUN wget http://labs.frickle.com/files/ngx_cache_purge-$nginx_cache_purge_version.tar.gz && \
    tar -xzvf ngx_cache_purge-$nginx_cache_purge_version.tar.gz && \
    rm -f ./ngx_cache_purge-$nginx_cache_purge_version.tar.gz

WORKDIR /tmp/nginx-installation/nginx-$nginx_version

RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-file-aio \
    --with-http_spdy_module \
    --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
    --with-ipv6 \
    --add-module=../ngx_cache_purge-$nginx_cache_purge_version && \
    make && \
    make install

RUN adduser --system --no-create-home --disabled-login --disabled-password --group nginx && \
    mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp

RUN mkdir -p /tmp/nginx/cache && \
    chown nginx:nginx /tmp/nginx/cache
ADD nginx.conf /etc/nginx/nginx.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]