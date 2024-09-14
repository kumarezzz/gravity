FROM httpd:2.4
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/kumarezzz/gravity.git /tmp/gravity
RUN cp -r /tmp/gravity/index.html /tmp/gravity/blog.html /tmp/gravity/breakfast.html \
    /tmp/gravity/burger.html /tmp/gravity/contact.html /tmp/gravity/hotdog.html \
    /tmp/gravity/shake.html /tmp/gravity/retrodiner.psd /tmp/gravity/css \
    /tmp/gravity/fonts /tmp/gravity/images /usr/local/apache2/htdocs/
EXPOSE 8090
CMD ["httpd-foreground"]
