#!/bin/bash

# Build Flutter web app
echo "🔨 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ -d "build/web" ]; then
    echo "✅ Build successful!"
    echo "🌐 Web app ready at build/web/"
else
    echo "❌ Build failed!"
    exit 1
fi
