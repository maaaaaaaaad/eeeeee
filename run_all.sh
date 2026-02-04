#!/bin/bash

echo "=== Flutter Clean ==="
flutter clean

echo ""
echo "=== Flutter Pub Get ==="
flutter pub get

echo ""
echo "=== Flutter Analyze ==="
flutter analyze

echo ""
echo "=== Flutter Test ==="
flutter test

echo ""
echo "=== Build Complete ==="
