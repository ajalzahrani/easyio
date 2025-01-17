#!/bin/bash

tar czf easyio.tar.gz main.js package.json public LICENSE
scp easyio.tar.gz aalzahrani@212.132.115.36:~
rm easyio.tar.gz

ssh aalzahrani@212.132.115.36 << 'ENDSSH'
pm2 stop all
rm -rf easyio
mkdir easyio
tar xf easyio.tar.gz -C easyio
rm easyio.tar.gz
cd easyio 
yarn install
pm2 start all
ENDSSH
