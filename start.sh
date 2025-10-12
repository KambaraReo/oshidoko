#!/bin/sh

# 本番環境でアセットプリコンパイルを実行
if [ "${RAILS_ENV}" = "production" ]
then
    echo "Precompiling assets..."
    bundle exec rails assets:precompile
fi

bundle exec rails s -p ${PORT:-3000} -b 0.0.0.0
