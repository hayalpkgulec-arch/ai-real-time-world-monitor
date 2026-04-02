# Use Node.js base image for web server
FROM node:18-alpine as web-server

# Install serve package for static files
RUN npm install -g serve

# Copy web build files
COPY /build/web /app

# Expose port
EXPOSE 8080

# Serve the app
CMD ["serve", "-s", "/app", "-l", "8080"]
