#!/bin/bash

echo "🛑 Flutter 프로세스 종료 중..."

pkill -f "flutter run" 2>/dev/null
pkill -f "flutter_tools" 2>/dev/null

ADB_BIN=~/Library/Android/sdk/platform-tools/adb

echo ""
echo "🔌 에뮬레이터 종료 중..."
$ADB_BIN -s emulator-5556 emu kill 2>/dev/null

echo ""
echo "📱 iOS 시뮬레이터 종료 중..."
xcrun simctl shutdown all 2>/dev/null

echo ""
echo "✅ 모든 프로세스 종료 완료"
