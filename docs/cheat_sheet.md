## Cheat sheet

A curated list of useful commands for developers working on this repo.

## Other useful rake tasks

```
rake db:reseed --clear, migrate, seed
```

```
rake db:reload --clear, migrate, seed, demo data
```

```
rake api:smoke_test  -- test basic API functionality
```

## Useful aliases

To ping all environments
```
alias ping.adp='for i in dev.claim-crown-court-defence.service.justice.gov.uk dev-lgfs.claim-crown-court-defence.service.justice.gov.uk staging.claim-crown-court-defence.service.justice.gov.uk api-sandbox.claim-crown-court-defence.service.justice.gov.uk claim-crown-court-defence.service.gov.uk ; do a="https://${i}/ping.json" ; echo $a; b=`curl --silent $a` ; echo $b; echo; done'
```
