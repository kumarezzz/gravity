FROM httpd:2.4
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/kumarezzz/gravity.git /tmp/gravity
RUN cp /tmp/gravity/index.html images layout pages /usr/local/apache2/htdocs/
EXPOSE 80
CMD ["httpd-foreground"]
