#!/bin/sh

# アセットプリコンパイルはDockerビルド時に完了済み
bundle exec rails s -p ${PORT:-3000} -b 0.0.0.0
