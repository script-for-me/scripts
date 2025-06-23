#!/bin/bash

set -e

# 1. Install nginx-full
apt install nginx-full -y

# 2. Define stream config
STREAM_CONFIG=$(cat <<EOF

# === Stream config inserted by script ===
stream {
    #atajan
    server {
        listen 4080;  
        proxy_pass 104.248.31.43:1080; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
    #atajan_main 
    server {
        listen 3060;  
        proxy_pass 138.124.24.96:1080; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    } 
    #makgy
     server {
        listen 4090;  
        proxy_pass 195.200.31.240:24; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
    #allas
    server {
        listen 3090;
        proxy_pass 195.200.31.89:24; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
    #Aina
    server {
        listen 3070;  
        proxy_pass 212.34.144.16:3956; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
    #unknown
    server {
        listen 2080;  
        proxy_pass 91.84.111.123:16; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
    #kemal
    server {
        listen 5020;  
        proxy_pass 195.200.30.46:17; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
    #bagtyyar
    server {
        listen 2077;  
        proxy_pass 203.18.98.182:1080; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
     #mx
    server {
        listen 2087;  
        proxy_pass 91.84.102.136:24; 
        proxy_connect_timeout 10s;
        proxy_timeout 300s;
    }
}

# === End stream config ===

EOF
)

# 3. Insert stream config between events {} and http {} in nginx.conf
NGINX_CONF="/etc/nginx/nginx.conf"

if ! grep -q "# === Stream config inserted by script ===" "$NGINX_CONF"; then
    echo "Inserting stream config into nginx.conf..."
    awk -v config="$STREAM_CONFIG" '
    BEGIN { inserted=0 }
    {
        print
        if ($0 ~ /^events *{/) found_events=1
        else if (found_events && $0 ~ /^}/ && !inserted) {
            print ""
            print config
            inserted=1
        }
    }' "$NGINX_CONF" > /tmp/nginx.conf.new && mv /tmp/nginx.conf.new "$NGINX_CONF"
else
    echo "Stream config already exists. Skipping insertion."
fi

# 4. Test and restart Nginx
nginx -t && systemctl restart nginx

echo "✅ Stream proxy inserted and Nginx restarted."
