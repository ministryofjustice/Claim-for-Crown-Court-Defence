## Build and Deploy

### CircleCI

CircleCI is configured such that:

1. merges to `master` will automatically build a docker container image for the app, tag it as `app-latest` and push to our AWS elastic container registry (ECR). The image will be smoke tested before then requiring approval for deployment.

2. branches have 2 separate workflows. The first runs the test suite against the branch without any user interaction. The second workflow requires approval to build a container and then enables deployment to individual non-production environments (approval required).

The build and deploy scripts can be found in the root `.circleci` directory.

### Kubernetes

CCCD's stack orchestration tool is kubernetes. Config for kubernetes can be found under the `kubernetes_deploy/` directory. Note, however, that the infrastructure is defined in the [Cloud platform environments repository](https://github.com/ministryofjustice/cloud-platform-environments)

Build and deploy from your local machine can be achieved using scripts in `kubernetes_deploy/scripts` *and can be used once you have access to AWS*. These facilitate the most common tasks, namely build, deploy, apply a job, apply a cronjob.


```
# build and deploy master to dev
kubernetes_deploy/scripts/build.sh
kubernetes_deploy/scripts/deploy.sh dev latest
```

#### Cronjobs

There are two cronjobs, `clean_ecr` and `archive_stale`. Any change to the `archive_stale` jobs config (`kubernetes_deploy/cron_jobs/archive_stale.yml`) are applied as part of the deployment process (because it relies on the app image), but any changes to the standalone `clean_ecr` job need to be applied from the commandline, as below

```
# apply changes to made to `kubernetes_deploy/cron_jobs/clean_ecr.yml`
kubernetes_deploy/scripts/cronjob.sh clean_ecr
```