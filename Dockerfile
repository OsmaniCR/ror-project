FROM ruby:3.2.0-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle
ENV PATH="/usr/local/bundle/bin:${PATH}"

COPY Gemfile Gemfile.lock* ./
RUN bundle install --jobs 4 --retry 3 --with development

COPY . .

EXPOSE 9292

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:9292", "config.ru"]
