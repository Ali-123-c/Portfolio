#!/bin/bash
set -e

echo "📦 Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable /tmp/flutter
export PATH="/tmp/flutter/bin:$PATH"

echo "🔧 Enabling web support..."
flutter config --enable-web --no-analytics

echo "📚 Getting dependencies..."
flutter pub get

echo "🏗️ Building for web..."
flutter build web --release

echo "✅ Build complete!"
