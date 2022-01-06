## Build and Deploy

- [circleCI](#circleci)
- [Kubernetes](#kubernetes)
- [Cronjobs](#cronjobs)
- [Container configuration and secrets](#container-configuration-and-secrets)

### CircleCI

CircleCI is configured such that:

1. merges to `master` will automatically build a docker container image for the app, tag it as `app-latest` and push to our AWS elastic container registry (ECR). The image will be smoke tested before then requiring approval for deployment.

2. branches have 2 separate workflows. The first runs the test suite against the branch without any user interaction. The second workflow requires approval to build a container and then enables deployment to individual non-production environments (approval required).

The build and deploy scripts can be found in the root `.circleci` directory.

### Kubernetes

CCCD's stack orchestration tool is kubernetes. Config for kubernetes can be found under the `.k8s/` directory. Note, however, that the infrastructure is defined in the [Cloud platform environments repository](https://github.com/ministryofjustice/cloud-platform-environments)

Build and deploy from your local machine can be achieved using scripts in `.k8s/<context>/scripts` *and can be used once you have access to AWS*. These facilitate the most common tasks, namely build, deploy, apply a job, apply a cronjob.


```
# build and deploy master to dev
.k8s/<context>/scripts/build.sh
.k8s/<context>/scripts/deploy.sh dev latest
```

#### Cronjobs

There are three cronjobs, `clean_ecr`, `archive_stale` and `vacuum_db`. Their config can be found in the `.k8s/<context>/cron_jobs` directory. Any change to the `archive_stale` and `vacuum_db` jobs config are applied as part of the deployment process because it relies on the app image, but any changes to the standalone `clean_ecr` job need to be applied from the commandline, as below.

```
# apply changes to made to `.k8s/<context>/cron_jobs/clean_ecr.yml`
.k8s/<context>/scripts/cronjob.sh clean_ecr
```

#### Container configuration and secrets

Environment specific configuration and secrets are handled by environment variables. Environment variables and their values fall into one of three categories:

- Non-secret app configuration
- Secret app configuration
- Secret infrastructure configuration

##### Non-secret app configuration
These are handled via sharable k8s [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) and then shared between relevant deployment files (app and worker) using the `envFrom` field with `configMapRef`.


```
# deployment.yaml - example reference for a ConfigMap
envFrom:
- configMapRef:
    name: cccd-app-config
```
An environment variable will be created with the name and value defined in the configmap file.

To add, remove or amend an environment variable you need to edit the ConfigMap file, `app-config.yaml`, and apply it.

```
kubetcl -n cccd-dev apply -f .k8s/<context>/dev/app-config.yaml
```

You will also need to restart the pod to pickup the changes.


##### Secret app configuration
Siimilar to ConfigMaps, these are handled via sharable k8s [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and then shared between relevant deployment files (app and worker) using the `envFrom` field with `secretRef`.


```
# deployment.yaml - example reference for a secret
envFrom:
  - secretRef:
      name: cccd-secrets
```
An environment variable will be created with the name and value defined in the secrets file.

To add, remove or amend a secret you need to edit the secret file, `secrets.yaml`, and apply it. You will need to be added as a git-crypt collaborator for this.

```
kubetcl -n cccd-dev apply -f .k8s/<context>/dev/secrets.yaml
```

You will also need to restart the pod to pickup the changes.

##### Secret infrastructure configuration
The [Cloud platform environment](https://github.com/ministryofjustice/cloud-platform-environments) repository is used to create infrastrucuture. Individual components may have secrets that the app will need access too (e.g. Database credentials). Since these secrets are controlled via the terraform templates we have little or no control over their naming. The apps configuration therefore needs to create environment variables it can use and set their value using the `deployment.yaml` `env` fields `valueFrom` `secretKeyRef`:

```
# deployment.yaml - example named env var with value coming from a specific secret key
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: cccd-rds
        key: url
```

See the [Cloud platform user guide](https://user-guide.cloud-platform.service.justice.gov.uk/#cloud-platform-user-guide) for help with adding, removing and changing infrastructure and their configuration.
