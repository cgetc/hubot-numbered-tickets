FROM node:0.10

RUN mkdir /bot && cd /bot
ADD . /bot

WORKDIR /bot

ENTRYPOINT ["bin/hubot", "--adapter", "slack"]
