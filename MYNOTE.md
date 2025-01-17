# Node.js Deploye Steps

Following youtube tutorial from Juriy Bura [Deploying Node Playlist](https://www.youtube.com/watch?v=1OU5ngq-WyM&list=PLQlWzK5tU-gDyxC1JTpyC2avvJlt3hrIh)

Install [easyio](https://github.com/Juriy/easyio) node app

### 1. Linux server setup

1. set up ssh
2. remote to linux server
3. run packages update & upgrade

```terminal
apt update
apt upgrade
apt install vim net-tools
```

### 2. Installing Node.js, PM2 and Yarn

1. install Node.js source package & node.js
   visit [nodesource](https://github.com/nodesource/distributions?tab=readme-ov-file#using-ubuntu-1) to find guid to install nodejs

```terminal
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
```

2. install pm2 & http-server & yarn

```terminal
npm install -g pm2 http-server
```

- http-server is only to check if you server can serve web-content

in root directory make sample html file:

```terminal
echo "Hello, World" > index.html
```

then start http-server

```terminal
http-server
```

- Install yarn from [offical yarn site](https://yarnpkg.com/)

### 3. How to Create Non-Root User

allows create non-root user to run application

create new user as the following:

```terminal
adduser aalzahrani
```

. create password and ... go home folder to setup ssh keys by creating new folder .ssh and change permission to only to new user, and create file called: authorized_keys and change permission to remove execution of that file.

```terminal
cd ~
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
```

Generate an SSH key pair by running:

```terminal
ssh-keygen -t rsa -b 4096 -C "server-ip-address"
```

Copy the public key to the remote server using 'ssh-copy-id'

```terminal
ssh-copy-id username@remote_server_ip
```

the public key will be added to ~/.ssh/authorized_keys

Configure SSH on remote server

open file /etc/ssh/sshd_config

```bash
vim /etc/ssh/sshd_config
```

Make sure the following settings are enabled

```plaintext
PubkeyAuthentication Yes
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
```

Restart ssh service

```terminal
ssh systemctl restart ssh
```

Save the file and exit

ssh to server using newely created user without password and check all packages installed.

### 4. Deploying Node.js app with PM2

In local machine go to nodejs project folder and comprise app files using:

```terminal
tar czf easyio.tar.gz main.js package.json yarn.lock public/ LICEANSE
```

c - comprise

z - zip

f - file

Then use scp to transfer tar file from local machine to remote server

```terminal
scp easyio.tar.gz 212.132.115.36:~
```

In the remote server extract easyio.tar.gz file using:

make a directory to unzip all files in side it.

```terminal
mkdir easyio
tar xf easyio.tar.gz -C easyio
```

download dependencies using yarn

and start the applicaiton, if everything goes well. then run the application using pm2

Run node.js app using PM2

```terminal
pm2 start --name easyio main.js
```

Make pm2 run on server startup

you have to root user to do the command

```termianl
pm2 startup systemd -u aalzahrani --hp /home/aalzahrani
```

login to normal user and check if pm2 still running, then execute

```terminal
pm2 save
```

which will make special file to tell pm2 on startup to run this processes currntly running.

### 5. Automate Node.js Deployment

Write bash script in your local machine to do all deploye process

Refere to [deploy.sh](./deploy.sh) and edit values according to your setup

### 6. How to Configure DNS

Point your domain to VPS ip address

### 7. NGINX as Reverse Proxy (listening on port 80)

### 8. SELinux (Security Enhanced Linux)

The goal of install SELinux is to imporve security and addtion layer of permissions

```terminal
apt install selinux-utils
```

Then type getenforece command to check the state of SELinux

```terminal
getenforece
```

Three possible result you may get:

1. Disabled - SELinux is disabled
2. Enforcing - Enabled and enforcing
3. Permissive - Enabled, but not enforcing (only logs violations, good for debugging)

### 8.1 Ubuntu Apparmor

apparmor is service used by debian systems

you can use systemctl to control apparmor service: enable, status, stop ...

```terminal
systemctl restart apparmor
```

you can referre back to [Create an AppArmor Profile for Nginx](https://www.digitalocean.com/community/tutorials/how-to-create-an-apparmor-profile-for-nginx-on-ubuntu-14-04) for detials steps in how to create nginx apparmor profile.

Usefull commands and directories:

### Install apparmor-profiles

```terminal
apt install apparmor-profiles
```

### Install apparmor-utils

```terminal
apt install apparmor-utils
```

### Print all profiles

```terminal
ss-status
```

This general process for enabling AppArmor for a new application is as follows:

- Create a new blank profile for the application
- Put it into complain mode
- Take normal actions with the application so appropriate entries get added to the logs
- Run the AppArmor utility to go through the logs and approve or disapprove various application actions

### 1. Create new blank profile for nginx

```terminal
aa-autodep nginx
```

Once profile created use:

### Move nginx profile to complain mode

```terminal
aa-complain nginx
```

to put the profile in complain mode.

### Read /var/log/syslog and checklist permission to be applied in nginx profile

```terminal
aa-logprof
```

### Move nginx profile to enfroce mode

```terminal
aa-enforce nginx
```

### Parse profile file syntax

```terminal
apparmor_parser -r /etc/apparmor.d/usr.sbin.nginx
```

Run this command after editing profile to check syntax

### Importent Directories and files

1. /etc/apparmor.d -- apparmor profiles
2. /var/log/syslog -- system log file where apparmor will log profiles activites
3.

### 9. Installing and Configuring NGINX on Ubuntu

```terminal
apt install nginx
```

Make sure the defualt NGINX page shows in broswer if you search for website.com

Set NGINX to start on startup

```terminal
systemctl enable nginx
```

NGINX config files can be found in:

```terminal
vim /etc/nginx/nginx.conf
```

Make a file for backend server conf in /etc/nginx/conf.d name it as domain name: ajzprotrack.com.conf

inside this file add server configurations

```config
server {
        listen 80;
        listen [::]:80;

        root /var/www/html;

        server_name ajzprotrack;

        # root          /usr/share/nginx/html;

        location / {
                proxy_pass "http://localhost:8080/";
        }

        error_page 404 /404.html;
        location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.htlm {
        }
}
```

after editing the file you can test using:

```termianl
nginx -t
```

and check for any error , expcted result:

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

after configure nginx you to reload

```
systemctl reload nginx
```

your website should up and running on port 80 using nginx reverse-proxy.

### 10. Proxying WebSockets with NGINX (Extra)

add new location and before default location for the webapp in ajzprotrack.com.conf for nginx conf file:

```conf
location /socket.io/ {
   proxy_http_version 1.1;

   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "upgrade"

   proxy_pass "http://localhost:8080/socket.io/";
}
```

This location will handle any webSocket connections by set new header proprities for Upgarde and Connection before pass the request to backend server (nodeapp)

you can read more about [Connection HTTP Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Connection)

you can read more about [Upgrade HTTP Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Upgrade)

#### next is to disable you node app from begin access from outside the server by point the to loopback interface in main.js

```javascript
server.listen(+port, "localhost", (err) => {
  if (err) {
    console.log(err.stack);
    return;
  }

  console.log(`Node [${name}] listens on http://127.0.0.1:${port}.`);
});
```

### 11. Client P in NGINX reverse proxy

1. Host
2. X-Real-IP
3. X-Forwarded-For

```conf
proxy_set_header Host $http_host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

right before any location to applied to all location

## Backup NGINX folder

copy nginx folder to user folder by:

```terminal
cp -r /etc/nginx .
```

comprise folder by:

```terminal
tar czf nginx.tar.gz nginx/
```

Download file using scp by:

```terminal
scp ajzprotrack.com:/home/aalzahrani/nginx.tar.gz ./Downloads/
```

### 12. Serving Static Files with NGINX

add root directive to sever configurations pointing to public/ folder within nodejs app

```conffig
root     /home/aalzahrani/eazyio/public;
```

To check permission to status files run:

```terminal
namei -om /home/aalzharni/easyio/public/
```

This command will display the access rights for the path.

Now we need to change the ownership of group aalzharni to nginx group so nginx gain access to home folder which has static files, but first we need to create nginx user for best practice:

First check the current user that nginx is using by:

```terminal
ps aux | grep nginx
```

Also you can check /etc/nginx/nginx.conf file first line, where you find user directive and the user

```terminal
sudo vim /etc/nginx/nginx.conf
```

This most properly will show www-data user for nginx, so it's best practice to let nginx have own user and group

```terminal
sudo adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx
```

This command creates a dedicated user and group nginx with limited login capabilities, ideal for running a secure web server.

```terminal
chown aalzahrani:nginx /home/aalzahrani
```

chnage group owner of /home/aalzahrani dirctory from aalzahrani to nginx group

refrere back to [SLING ACADEMY](https://www.slingacademy.com/article/nginx-user-and-group-explained-with-examples/) for more details

Now after changing the ownership to nginx group. NGINX is ready to serve static files by using root directive.

also you need to change location directive in /etc/nginx/conf.d/ajzprotrack.com.conf

From:

```conf
location / {
                proxy_pass "http://localhost:8080/";
        }
```

To:

```conf
location /api/ {
                proxy_pass "http://localhost:8080/api/";
        }
```

To make sure nginx is serving the static files login to user account, and stop pm2

```terminal
pm2 stop all
```

browser [ajzprotrack.com](http://ajzprotrack.com) again, you will find html public folder (html, js, and css) served to the browser. This will indecate that now NGINX is handling static files instead of nodejs app.

### 13 How to Install SSL Certificate and Configure HTTPS

You can obtin free certificate from letsecrypte using certbot

in my case my host provided me with a free certificate

to install the certificate to NGINX, first you have to visit [Mozila SSL Generator](https://ssl-config.mozilla.org/) to get NGINX https server template for SSL

Copy and paste template to /etc/nginx/conf.d/ajzprotrack.com.conf and change parameter (Follow <---- this line ). just bellow http server

```conf
# HTTP server
server {
    ....
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name     ajzprotrack.com;
    root            /home/aalzahrani/easyio/public/;

    ssl_certificate /path/to/certificate/combined; <---- this line
    ssl_certificate_key /path/to/private/key; <---- this line
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
    ssl_session_tickets off;

    # modern configuration
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers off;

    # HSTS (ngx_http_headers_module is required) (63072000 seconds)
    add_header Strict-Transport-Security "max-age=63072000" always;

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;

    # Comment bllow OCSP conf <---- this line
    # verify chain of trust of OCSP response using Root CA and Intermediate certs
    # ssl_trusted_certificate /path/to/root_CA_cert_plus_intermediates;

    # replace with the IP address of your resolver
    resolver 8.8.8.8; <---- this line
}

```

### !IMPORTENT NOTE

you have to combine original certificate with intermediate certificate and make one file for them. use:

```terminal
cat original_certificate.cert intermediate_certificate.cert > combinde_certificate.crt
```

Referre back to [NGINX Docmentation](https://nginx.org/en/docs/http/configuring_https_servers.html#chains) for more details.

now just write the path of both combinde and private certs to /etc/nginx/conf.d/ajzprotrack.com.conf file.

copy http header configuration from http server and paste it in https server right after resolver directive.

```conf
  ....

  resolver 8.8.8.8

  proxy_set_header Host $http_host
  ....
```

In http server just add redirection to https server:

```conf
server {
        listen          80;
        listen          [::]:80;
        server_name     ajzprotrack.com;
        location / {
                return 301 https://$host$request_uri;
        }
}
```

so now any incoming request to http will be redirect to https, to test this
use curl:

```terminal
curl -v ajzprotrack.com
```

expected result is:

```terminal
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.18.0 (Ubuntu)</center>
</body>
</html>
```

At this point don't forget to backup /etc/nginx folder

### 14. Load Balancing with NGINX

Why Load Balancing?

1. Distributing the load between processes and/or hosts.
2. Failover: while one node is donw, users are served by other nodes.
3. Zero downtime redeploy.

Now stop pm2 and delete all instances managed by pm2

```terminal
pm2 stop all
pm2 delete all
```

Start new instance as the following:

```terminal
pm2 start --name easy-1 main.js -- --name easy-1 --port 8080
```

- pm2 start - will start new instance
- --name - to give a name for instance
- easy-1 - instance name
- main.js - nodejs app file
- /-- - allow pass more argument to nodejs app
- --name - nodejs argument
- easy-1 - nodejs arugment
- --port - nodejs port

Start another instance of same nodjsapp

```terminal
pm2 start --name easy-2 main.js -- --name easy-2 --port 8081
```

Now pm2 serving two instances of nodejs app. easy-1 & easy-2
but nginx doesn't know about easy-2 now.

To configure nginx to load balance these two instances
you have to add upstream directive just right before servers configuration in /etc/nginx/conf.d/ajzprotrack.com.conf

```conf
upstream easyio {
  server localhost:8080;
  server localhost:8081;
}
# Http server
server {
  ....
}
# Https server
server {
  ....
}
```

Now change proxy_pass directive to point to upstream name instade of localhost

Change location proxy_pass

From:

```conf
location /socket.io/ {
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_pass "http://localhost:8080/socket.io/";
}

location /api/ {
    proxy_pass "http://localhost:8080/api/";
}
```

To:

```conf
location /socket.io/ {
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_pass "http://easyio/socket.io/";
}

location /api/ {
    proxy_pass "http://easyio/api/";
}
```

Save and reload nginx

you will notice the app hearbeat is borken that is because webSocket hand shake

to fix this issue you just need to add ip_hash; directive to upstream

```conf
upstream easyio {
    ip_hash;
    server localhost:8080;
    server localhost:8081;
}
```

ip_hash in upstram will connect the client directly with nodejs instance.

### Failover

Now NGINX load balancing between two appjs instances easy-1 & easy-2
visit the app from browser and see which instace serving, then login to user and turn off that instance, go back to browser you will see that nginx will immidtly connect to the other instance.

At this point don't forget to execute:

```terminal
pm2 save
```

To save current process list
