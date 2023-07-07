# To Build Docker
# flutter build web
# docker build -t oes-web .

# To Run Docker
# docker run -d -p 8003:80 oes-web

FROM httpd:2.4
COPY ./build/web/ /usr/local/apache2/htdocs/