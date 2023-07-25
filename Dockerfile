# To Build Docker
# flutter build web

# Build Normal
# docker build -t oes-web .

# Build Multi Arc
# docker buildx create --name mybuilder
# docker buildx use mybuilder
# docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t oes-web .

# To Run Docker
# docker run -d --restart unless-stopped -p 8003:80 oes-web

FROM httpd:2.4
COPY ./build/web/ /usr/local/apache2/htdocs/