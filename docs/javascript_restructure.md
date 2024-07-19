## Javascript restructure

### Motivation

A style guide is provided for Javascript in Gov.UK sites at https://github.com/alphagov/govuk-frontend/blob/main/docs/contributing/coding-standards/js.md

Currently the Javascript modules in CCCD do not follow this guide and instead modules are defined in two different ways;

Executing a function expression to return an object;

```javascript
// app/webpack/javascripts/modules/Helpers.API.Core.js

(function (exports, $) {
  const Module = exports.Helpers.API || {}

  ...

  Module._CORE = {
    query
  }

  exports.Helpers.API = Module
}(moj, jQuery))
```

Adding to the `moj` module so that it is initialized together with all modules by `moj.init()` in `app/webpack/javascripts/application.js`;

```javascript
// app/webpack/javascripts/modules/Helpers.DataTables.js

moj.Helpers.DataTables = {
  init: function (options, el) {
    ...
  },

  ...
}
```

The Gov.UK style guide recommends using the class design pattern to structure the code;

```javascript
class Example {
  // Code goes here
}
```

The primary benefits of refactoring our Javascript is to have a single, consistent style so that future developers can better understand the codebase.
Specifically using the recommended Gov.UK style will further facilitate new developers who have worked on other Gov.UK projects.

This is a *work in progress* so javascript modules may be written in any of the above formats but the ideal is the class design pattern.

### Removal of jQuery

There has also been a long-standing plan to remove the dependency on jQuery as modern versions of Javascript have all (most?) of the features that jQuery provided. There are some [notes here](https://tobiasahlin.com/blog/move-from-jquery-to-vanilla-javascript/) to help with migrating jQuery to vanilla Javascript and below are some further pointers.

#### Accessing the data of elements

jQuery provides a way of accessing data from elements as follows;

```javascript
// <table id="determinations" data-scheme="agfs">

table = $('#determinations')
scheme = table.data('scheme')
```

Without jQuery this becomes;

```javascript
// <table id="determinations" data-scheme="agfs">

table = document.getElementById('determinations')
scheme = table.dataset.scheme
```

#### DataTable

CCCD uses the DataTable library in various places and this is built on jQuery a replacement will need to be found. One possibility is [Simple-DataTable.](https://github.com/fiduswriter/Simple-DataTables)

### Running tests

Jasmine tests are run with:

```bash
bundle exec rails jasmine:run
# or
npx jasmine-browser-runner runSpecs
```

To view the test output in the browser the server needs to be run before the tests:

```bash
npx jasmine-browser-runner serve
```

and then view the output at http://localhost:8888

In particular, this makes it possible to view the output of `console.log`.

### Linting

`yarn standard` will complain about the use of `Response` in `app/webpack/javascripts/modules/determination_spec.mjs`
(for example) even though it is part of [ES6.](https://caniuse.com/mdn-api_response_response)
This is due to some dependencies that, it is hoped, will be removed after the
cleanup is completed. `"Response"` is added to the `globals` section of the
`standard` configuration in `package.json`.