FROM ruby:2.7.5

ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development:test

# yarnをインストール
RUN apt-get update && apt-get install -y curl apt-transport-https wget && \
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
apt-get update && apt-get install -y yarn

# nodejsをインストール
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && apt-get install -y nodejs

# コンテナ内にmyappディレクトリを作成
RUN mkdir /myapp

# 作成したmyappディレクトリを作業用ディレクトリとして設定
WORKDIR /myapp

# ローカルの Gemfile と Gemfile.lock をコンテナ内のmyapp配下にコピー
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

# コンテナ内にコピーした Gemfile の bundle install
RUN bundle install

# ローカルのmyapp配下のファイルをコンテナ内のmyapp配下にコピー
COPY . /myapp

# アセットをプリコンパイル（ビルド時に実行）
RUN RAILS_ENV=production bundle exec rails assets:precompile

# コンテナ起動時に実行させるスクリプトを追加
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

COPY start.sh /start.sh
RUN chmod 744 /start.sh
CMD ["sh", "/start.sh"]
