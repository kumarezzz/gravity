FROM httpd:2.4
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/kumarezzz/gravity.git /tmp/gravity
RUN cp -r /tmp/gravity/{index.html,blog.html,breakfast.html,burger.html,contact.html,hotdog.html,shake.html,retrodiner.psd,css,fonts,images} /usr/local/apache2/htdocs/
EXPOSE 80
CMD ["httpd-foreground"]
