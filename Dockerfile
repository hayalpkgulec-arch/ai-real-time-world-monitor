# Multi-stage build for Flutter web app
FROM cirrusci/flutter:stable as flutter-build

# Set working directory
WORKDIR /app

# Copy flutter app files
COPY aegis_app/ ./

# Get dependencies
RUN flutter pub get

# Build web app
RUN flutter build web --release

# Production stage
FROM nginx:alpine

# Copy built web app to nginx
COPY --from=flutter-build /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
