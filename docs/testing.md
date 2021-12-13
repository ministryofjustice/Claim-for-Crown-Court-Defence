## Testing and Linting

A combination of unit testing (rspec and jasmine), feature test (cucumber) and static analysis (rubocop, brakeman) make up the test suite. You can run the entire test suite you can use by calling `rake` from the commandline.

The CI lints SASS and JavaScript using npm and yarn.

## Unit testing

To execute unit tests

```
bundle exec rspec
bundle exec rake jasmine:run
```

### Javascript Unit Testing

Run it using the `guard` command. Jasmine output available here: [http://localhost:8888](http://localhost:8888)

## Features tests

To execute cucumber feature tests

```
bundle exec cucumber
```

## Parallel spec running

There are over 10k of rspec examples. This can take in excess of an hour to run locally in a single process. To run rspec examples in parallel, in as many processes as you have cores, you can use the following setup and execution. It should reduce the runtime to
approximately 15 minutes on an 8 core machine.

- One time setup
  ```
  rake parallel:create
  rake parallel:prepare
  rake parallel:migrate # needed after each migration
  ```
  *see [parallet_test setup for rails](https://github.com/grosser/parallel_tests#setup-for-rails) for more*


- Then to execute...
  ```
  rake parallel:spec
  ```
  *see [parallel_test running](https://github.com/grosser/parallel_tests#run) for more*

## Parallel feature running

While `rake parallel:features` will run the cucumber features in parallel they will error for various reasons. See [parallel_test getting stuff running wiki](https://github.com/grosser/parallel_tests/wiki) for various potential fixes.

## Linting

### Sass Linting

To ensure code quality and consistency in our Sass files we check that certain
style rules are followed. These rules are based on [stylelint-config-gds](https://github.com/alphagov/stylelint-config-gds/blob/main/scss.js)

All Sass (except vendor files) files follow its rules, and it runs on git pre-commit to ensure that commits are in line with them.

You can manually run it using `$ yarn run validate:scss`

### Javascript Linting

CCCD uses [standardjs](http://standardjs.com/), an opinionated JavaScript linter. All JavaScript (except vendor files) files follow its conventions, and it runs on git pre-commit to ensure that commits are in line with them.

You can manually run it using `$ yarn run validate:js`

## How we test external services

#### LAA fee calculator API

##### RSpec
Some rspec unit tests require VCR cassettes for the LAA fee calculator API external service. These specs are tagged with `:fee_calc_vcr` so can be targetted using rspec cmdline options.

```bash
# run specs requiring LAA fee calculator API call stubs/cassettes
$ rspec --tag fee_calc_vcr

```

Changes to the calling of the LAA fee calculator API will most likely require you to rerecord the VCR cassettes that stub these calls. To rerecord VCR cassettes you can delete the existing ones (in `vcr/cassettes/spec`). They will be recreated when the specs are run.

It is a good idea to do this when changes occur to the LAA fee calculator API too.

##### Cucumber
Some cucumber features require VCR cassettes to stub calls to the LAA fee calculator API. These features require and are tagged with a `@fee_calc_vcr` tag. To re-record the cassettes delete the existing ones and run the feature again. See
[Create a new VCR cassette](#create-new-vcr-cassette).

For convenience the VCR recording mode for all cucumber scenarios tagged with `@fee_calc_vcr` can be changed by supplying an enviroment variable from the commandline.

```bash
# delete a bunch of fee calculator features
$ rm -rf vcr/cassettes/features/fee_calculator/

# run applicable features and set recording mode to 'new_episodes' if the scenario is tagged with @fee_calc_vcr
$ FEE_CALC_VCR_MODE=new_episodes cucumber features/fee_calculator/

# or run all those tagged with @fee_calc_vcr
$ FEE_CALC_VCR_MODE=new_episodes cucumber --tag @fee_calc_vcr
```

#### Internal API
Some cucumber feature tests use VCR to record/store mock results the internal API calls (calling our own API) for certain endpoints (case worker claims in particular).
To create a new feature/scenario that relies on such endpoints you will therefore need to record a new "cassette", as below.

##### Create new VCR cassette

Run this in a new console:

```bash
# Start internal API for use by test suite
$ RAILS_ENV=test rails s -p 3001 -P /tmp/rails3001.pid
```

In your `.feature` file add this step before any calls relying on the internal API - i.e. which will be mocked by the cassette produced:

```ruby
# default recording mode has been set to `:once` so it will create a new cassette of the given name if there is not one.
And I insert the VCR cassette 'features/case_workers/claims/injection_error'
```

You can change the default recording mode (:once) by adding `and record 'all|new_episodes|none|once'` to the end of this step
```ruby
# record new vcr episodes. Remember to remove this once they are recorded.
And I insert the VCR cassette 'features/case_workers/claims/injection_error' and record 'new_episodes'
```

Add this step at the point you want to stop recording and write the output to the cassette file:

```ruby
# eject the previously inserted cassette (optional if there already is one but needs to be done if a new is being created in order to output the file
And I eject the VCR cassette
```

Run the feature:
```bash
# note: the 0000.feature is run first to clear the db - not sure if still/always needed
cucumber features/000.feature features/injection_errors.feature
```

After you have run it once you must amend the cassette inserting step as below if you added `and record 'all|new_episodes'` to prevent it creating new cassettes on each run:

```ruby
And I insert the VCR cassette 'features/case_workers/claims/injection_error'
```

You are done. To test terminate/prevent the api service that the test relies on from running - in our example Crtl+c on the console running the rails server on port 3001 - and run the
feature again. It should no longer require the api endpoints.

You should now commit the cassette to the repo to ensure it is not unneccessarily created by upstream test suite runs on the CI solution.

***When you change a feature test such that you need to re-record its cassette you should delete the existing cassette in the `vcr` folder and proceed as if creating a new cassette, above.***
