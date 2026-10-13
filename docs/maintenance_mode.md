## Maintenance mode

A conditional catchall routes exists in `routes.rb`. This directs all routes requested to the `pages#servicedown` controller and view. To activate the conditional route you must provide the app server with MAINTENANCE_MODE=true. Note that dotenv files cannot be used to set these envvars locally as the config gem (`settings.yml` file) is loaded before dotenv files.

```bash
# activate maintenance mode locally
MAINTENANCE_MODE=true rails s
```

You can deploy the app in maintenance mode for Kubernetes environments from your local machine or through GitHub Actions. Either method requires amending the `deployment.yaml` file for the relevant environment to add the `MAINTENANCE_MODE` environment variable with a value of `'true'`.

example `deployment.yaml` config:
```yaml
env:
  - name: MAINTENANCE_MODE
    value: 'true'
```

To apply via GitHub Actions:

- commit the change, push the branch, and open a pull request to `main`
- `.github/workflows/pull_request_deploy.yml` builds and deploys same-repository pull requests to dev, dev-lgfs, API sandbox, and staging; it does not provide a single-environment selector
- after merging, `.github/workflows/ci_cd.yml` deploys the main branch; production deployment follows the main and development UI smoke tests and may also require approval configured in the GitHub environment
- to take the site out of maintenance, commit the reverse change and deploy it through the same workflow


To apply via local machine:

- you will need all relevant aws credentials
- amend `deployment.yaml`, as above, and run the deploy script, as below.
- to take site out of maintenance amend `MAINTENANCE_MODE` to `'false'` and run the deploy script again.

```bash
# deploying to dev from local machine
.k8s/live/scripts/deploy.sh dev latest
```
