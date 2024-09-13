FROM httpd:2.4
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/kumarezzz/gravity.git /tmp/gravity
RUN cp -r /tmp/gravity/index.html /tmp/gravity/images /tmp/gravity/layout /tmp/gravity/pages /usr/local/apache2/htdocs/
EXPOSE 80
CMD ["httpd-foreground"]
