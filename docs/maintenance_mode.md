## Maintenance mode

A conditional catchall routes exists in `routes.rb`. This directs all routes requested to the `pages#servicedown` controller and view. To activate the conditional route you must provide the app server with MAINTENANCE_MODE=true. Note that dotenv files cannot be used to set these envvars locally as the config gem (`settings.yml` file) is loaded before dotenv files.

```bash
# activate maintenance mode locally
MAINTENANCE_MODE=true rails s
```

You can deploy the app in maintenance mode for kubernetes orchestrated environments by deploying either from your local machine or via circleCI. Either method requires you to amend the `deployment.yaml` file for the relevant environment to add the env var `MAINTENANCE_MODE` with a value `'true'`.

example `deployment.yaml` config:
```yaml
env:
  - name: MAINTENANCE_MODE
    value: 'true'
```

To apply via circleCI:

- commit the above change and push to github
- run through circleCI and deploy to the relevant environment
- For production environment you will need to merge to main and use its workflow
- to take site out of maintenance you would have to commit the reverse and redeploy via circleCI


To apply via local machine:

- you will need all relevant aws credentials
- amend `deployment.yaml`, as above, and run the deploy script, as below.
- to take site out of maintenance amend `MAINTENANCE_MODE` to `'false'` and run the deploy script again.

```bash
# deploying to dev from local machine
.k8s/live/scripts/deploy.sh dev latest
```
