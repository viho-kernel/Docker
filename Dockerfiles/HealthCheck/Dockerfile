FROM nginx:latest 

WORKDIR /app 
# Custom Labels
LABEL maintainer="Vihari Reddy"  
LABEL version="1.0"
LABEL description="A simple Nginx Application"

RUN echo "This is a test file created during build" > test.txt

COPY index.html .

# Also copy HTML into Nginx’s default path so you can see it in browser
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

# The HEALTHCHECK instruction tells Docker how to test a container to check that it's still working
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --start-interval=5s --retries=3 CMD curl -f http://localhost/ || exit 1