#Cucumber test structure

This should be used as a guide to help improve the quality of our cucumber tests and help us manage them.

##Directories

- features
	- *case_workers*
	- examples
	- external_users
		+ advocates
		+ litigators
		+ shared
	- step_definitions
	- support

___

##Tags

| Tag                              | Description |
|----------------------------------|-------------|
| @javascript                      | Uses a javascript-aware system to process web requests (e.g., Selenium) instead of the default (non-javascript-aware) webrat browser. |
| @webmock_allow_localhost_connect | [Webmock](https://github.com/bblimke/webmock) Library for stubbing and setting expectations on HTTP requests in Ruby. |
| @WIP								| Work in progress
| @advocate                        | All advocate journeys - eg. login, submit a new claim,   |
| @caseworker                      | All case worker journeys - eg admin logins and allocates claims and a case worker |
| @litigator                       | All ligitgator journeys |
| @admin                           | Any administration related tasks from either advocate,case worker or litigators |
| @api-sandbox                     | Relates to API testing |                | @vendor                          | All tests for third party vendors |
| @process_claim                   | All the features that are needed from allocation right through to the point of authorised/part-authorised/rejected/refused |
| @submit_claim                    | All the features that are needed to submit a claim|

Decided not to have a @shared tag because you can run tests for any combination of tags.

```
cucumber --tags @advocate, @caseworker
```
The example above would run all scenarios that had @advocate or @caseworker tag

Reference: [Logically ANDing and ORing tags](https://github.com/cucumber/cucumber/wiki/Tags#logically-anding-and-oring-tags)
