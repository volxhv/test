FROM nginx:1.27-alpine
RUN apk add --no-cache openssl
COPY gateway-entry.sh /gateway-entry.sh
RUN chmod +x /gateway-entry.sh
ENTRYPOINT ["/gateway-entry.sh"]
