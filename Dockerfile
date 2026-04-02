# Multi-stage build for Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.41.6 as flutter-build

# Set working directory
WORKDIR /app

# Copy only pubspec files first for better caching
COPY aegis_app/pubspec.yaml ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the app
COPY aegis_app/ ./

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
