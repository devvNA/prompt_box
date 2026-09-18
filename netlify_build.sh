#!/bin/bash

# 1. Clone Flutter stable branch
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable

# 2. Add flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Create .env file from Netlify Environment Variables (fallback for flutter_dotenv)
echo "Creating .env file..."
echo "SUPABASE_URL=$SUPABASE_URL" > .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env

# 4. Get dependencies and build
echo "Building Flutter Web..."
flutter clean
flutter pub get
flutter build web --release --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "Build successful!"
