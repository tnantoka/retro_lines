#!/bin/sh

set -eu

git clone https://github.com/flutter/flutter.git -b stable --depth 1 bin/flutter

./bin/flutter/bin/flutter build web --release
