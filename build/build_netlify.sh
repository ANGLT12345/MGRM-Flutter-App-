# build/build_netlify.sh
#!/usr/bin/env bash
set -euo pipefail
export FLUTTER_ROOT="$HOME/flutter"

# Install Flutter (clone stable if not already cached)
if [ ! -d "$FLUTTER_ROOT" ]; then
  echo "Cloning Flutter SDK (stable)..."
  git clone -b stable https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
fi

export PATH="$FLUTTER_ROOT/bin:$PATH"

# Ensure web support and cache web artifacts
flutter config --enable-web
flutter precache --web

# Dependencies and build
flutter pub get
flutter build web --release