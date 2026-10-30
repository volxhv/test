FROM nginx:1.27-alpine
COPY app-nginx.conf /etc/nginx/conf.d/default.conf
