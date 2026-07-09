FROM nginx:1.27-alpine

LABEL project="red-tide-risk"
LABEL description="Red tide risk visualization static site"

COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY dist/ /usr/share/nginx/html/red-tide-risk/

RUN find /usr/share/nginx/html/red-tide-risk -type f -exec chmod 0644 {} \; \
    && find /usr/share/nginx/html/red-tide-risk -type d -exec chmod 0755 {} \;

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
