FROM nginx:latest 

WORKDIR /app 

RUN echo "This is a test file created during build" > test.txt

COPY index.html .

# Also copy HTML into Nginx’s default path so you can see it in browser
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80