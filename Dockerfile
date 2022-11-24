FROM ruby:3.1 as builder

RUN apt update
RUN apt install -y build-essential \
    libfreeimage-dev \
    libcurl4
RUN gem install bundler
WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
ENV BUNDLE_JOBS=4
RUN bundle install

FROM ruby:3.1
MAINTAINER O. Yuanying "yuan-docker@fraction.jp"

RUN gem install bundler
WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY --from=builder /usr/local/bundle /usr/local/bundle

ENV APP_HOME /usr/src/app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME

CMD ["bundle", "exec", "ruby", "main.rb"]
