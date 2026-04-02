# Build stage
FROM ghcr.io/cirruslabs/flutter:3.41.6 as flutter-build

WORKDIR /app

# Copy pubspec and get dependencies
COPY aegis_app/pubspec.yaml ./
RUN flutter pub get

# Copy source code
COPY aegis_app/ ./

# Build web app
RUN flutter build web --release

# Production stage - use simple static server
FROM node:18-alpine

# Install serve
RUN npm install -g serve

# Copy built web app to correct location
COPY --from=flutter-build /app/build/web /app/build/web

WORKDIR /app/build/web

# Expose port
EXPOSE 8080

# Serve the app from correct directory
CMD ["serve", "-s", ".", "-l", "8080"]
