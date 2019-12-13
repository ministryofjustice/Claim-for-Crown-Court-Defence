FROM ruby:2.6.5-alpine3.10
LABEL "maintainer"="Ministry of Justice, Claim for crown court defence <crowncourtdefence@digital.justice.gov.uk>"

LABEL "com.github.actions.name"="Delete ECR image"
LABEL "com.github.actions.description"="Delete the ECR image for this branch"
LABEL "com.github.actions.icon"="activity"
LABEL "com.github.actions.color"="red"

# install dependencies
RUN apk --no-cache add git

COPY entrypoint.sh /usr/local/bin/delete-ecr-images

RUN set -ex && \
  chmod +x /usr/local/bin/delete-ecr-images

ENTRYPOINT ["delete-ecr-images"]
