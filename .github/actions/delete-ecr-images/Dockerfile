FROM ruby:2.6.5-alpine3.10
LABEL "maintainer"="Ministry of Justice, Claim for crown court defence <crowncourtdefence@digital.justice.gov.uk>"

LABEL "com.github.actions.name"="Delete ECR image"
LABEL "com.github.actions.description"="Delete the ECR image for this branch"
LABEL "com.github.actions.icon"="activity"
LABEL "com.github.actions.color"="red"

# install dependencies

RUN apk update && \
  apk --no-cache add git python py-pip

RUN pip install awscli

RUN apk --purge -v del py-pip && \
  rm /var/cache/apk/*

COPY entrypoint.sh /usr/local/bin/delete-ecr-images

RUN set -ex && \
  chmod +x /usr/local/bin/delete-ecr-images

ENTRYPOINT ["delete-ecr-images"]
