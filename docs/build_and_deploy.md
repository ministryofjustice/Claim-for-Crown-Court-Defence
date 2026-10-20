## Build and Deploy

- [Build and Deploy](#build-and-deploy)
  - [GitHub Actions](#github-actions)
  - [Kubernetes](#kubernetes)
    - [Cronjobs](#cronjobs)
    - [Container configuration and secrets](#container-configuration-and-secrets)
      - [Secret management](#secret-management)
      - [Non-secret app configuration](#non-secret-app-configuration)
      - [Secret app configuration](#secret-app-configuration)
      - [Secret infrastructure configuration](#secret-infrastructure-configuration)

### GitHub Actions

GitHub Actions workflows are defined in `.github/workflows`.

- `pull_request_tests.yml` runs the test suites and code checks for pull requests targeting `main`.
- `pull_request_deploy.yml` builds and pushes a pull request image, then deploys it to non-production environments for pull requests from this repository.
- `ci_cd.yml` runs on pushes to `main` and on a schedule. For pushes, it runs the test suites before building and pushing the image to AWS ECR. It then deploys to development, API sandbox, dev-lgfs, and staging (with manual trigger required). Production deployment is additionally gated by the main and development UI smoke tests. The scheduled run performs smoke tests.

The workflows use the shared build script at `.github/build.sh` and the deployment scripts under `.k8s/live/scripts`.

### Kubernetes

CCCD's stack orchestration tool is kubernetes. Config for kubernetes can be found under the `.k8s/` directory. Note, however, that the infrastructure is defined in the [Cloud platform environments repository](https://github.com/ministryofjustice/cloud-platform-environments)

Build and deploy from your local machine can be achieved using scripts in `.k8s/<context>/scripts` *and can be used once you have access to AWS*. These facilitate the most common tasks, namely build, deploy, apply a job, apply a cronjob.


```
# build and deploy main to dev
.k8s/<context>/scripts/build.sh
.k8s/<context>/scripts/deploy.sh dev latest
```

#### Cronjobs

There are two cronjobs, `archive_stale` and `vacuum_db`. Their config can be found in the `.k8s/<context>/cron_jobs` directory. Any change to the `archive_stale` and `vacuum_db` jobs config are applied as part of the deployment process because it relies on the app image.

#### Container configuration and secrets

Environment specific configuration and secrets are handled by environment variables. Environment variables and their values fall into one of three categories:

- Non-secret app configuration
- Secret app configuration
- Secret infrastructure configuration


##### Secret management

Secrets should not be kept in this repository. In the past `git-crypt` has been used to encrypt secrets within the repo however due to the difficulty of rotating the symmetric key used for encryption following a security breach, this approach has now been deprecated.

Secrets are held as Kubernetes Secret objects in the cluster. These can be accessed by executing

```bash
kubectl -n cccd-<env> get secrets
```

when authenticated to the cluster to view a list of all secrets.

To view the contents of a Secret, execute:

```bash
kubectl -n cccd-<env> get secrets <secret-name> -o json
```

For more details on how to add or update Kubernetes Secrets, see the [Cloud Platform documentation](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/add-secrets-to-deployment.html#adding-a-secret-to-an-application).

Secrets are also held securely in a password management service. This provides redundancy in the event that a Kubernetes Secret is deleted from the cluster; it can be recreated using the data held in the backup.

There is no automatic syncing of secrets between these backups and Kubernetes. If secret data is added or changed in one, it must be manually reflected in the other. Please refer to this [Confluence document](https://dsdmoj.atlassian.net/wiki/spaces/CFP/pages/4273504650/Secrets+Strategy+Post+Git-Crypt#Where-We-Are-Storing-Secrets-Now) document for more information.


##### Non-secret app configuration
These are handled via sharable k8s [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/) and then shared between relevant deployment files (app and worker) using the `envFrom` field with `configMapRef`.

`DUAL_LOGIN_ENABLED` defaults to `false` (original password login plus the approved-tester pilot).
Set it to `true` for public email-first rollout, with master feature flags enabled. Changing it requires
rollout/restart across instances. Deploy the tester-column migration before the new code.
Check existing login-route coverage separately; the tester-column migration does not repair missing routes
or approve accounts. Superadmins can manage approval and the Legacy/Entra login method separately in
**Dual-login testing**. Verify both flows and live Microsoft authentication before public rollout.
To roll back to the restricted pilot, disable `DUAL_LOGIN_ENABLED`, remove any `dual_login` entry in
`active_features`, check settings overrides, and restart all instances. This does not end existing
authenticated sessions or completely disable the approved-tester pilot.


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
Similar to ConfigMaps, these are handled via sharable k8s [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) and then shared between relevant deployment files (app and worker) using the `envFrom` field with `secretRef`.

```
# deployment.yaml - example reference for a secret
envFrom:
  - secretRef:
      name: cccd-env-vars
```
An environment variable will be created with the name and value defined in the secrets file.

To add, remove or amend a secret you need to create a secret file and apply it.

```
kubetcl -n cccd-dev apply -f <secret_file>
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
