FROM ruby:2.2.4-onbuild
MAINTAINER Marco Carvalho <marco.carvalho.swasthya@gmail.com>
ENV RABBITMQ_PORT=5672
ENV RABBITMQ_HOST=rabbitmq
WORKDIR /usr/src/app/
CMD /usr/local/bin/ruby lib/mb-fetcher.rb

# environment:
#   RABBITMQ_HOST: localhost
#   RABBITMQ_USER: guest
#   RABBITMQ_PASS: guest