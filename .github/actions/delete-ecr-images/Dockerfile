FROM ruby:3.1.2-alpine3.15
LABEL "maintainer"="Ministry of Justice, Claim for crown court defence <crowncourtdefence@digital.justice.gov.uk>"

LABEL "com.github.actions.name"="Delete ECR image"
LABEL "com.github.actions.description"="Delete the ECR image for this branch"
LABEL "com.github.actions.icon"="activity"
LABEL "com.github.actions.color"="red"

# install dependencies

RUN apk update \
    && apk add --no-cache git python3 py3-pip

RUN pip3 install --upgrade pip \
    && pip install awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version

COPY entrypoint /usr/local/bin/delete-ecr-images

ENTRYPOINT ["delete-ecr-images"]
