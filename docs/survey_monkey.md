# Survey Monkey

## Survey configuration

Submitting survey results to Survey Monkey requires the following details:

* Access token
* Collector id
* Question ids

### Access token

The auth token can be found from the [developer dashboard](https://developer.eu.surveymonkey.com/apps/)
inside the settings for an app. This is used for `SURVEY_MONKEY_BEARER_TOKEN`
and as the bearer token for fetching ids, below.

### Survey id

The id of a survey is required to fetch the collector ids and question ids,
below. A list of all surveys can be found with:

```sh
curl --request GET \
     --url https://api.eu.surveymonkey.com/v3/surveys \
     --header 'Accept: application/json' \
     --header 'Authorization: Bearer <access token>' \
     | jq
```

This will return

```json
{
  "data": [
    {
      "id": "230446645",
      "title": "Claim for Crown Court Defence Feedback",
      "nickname": "",
      "href": "https://api.eu.surveymonkey.com/v3/surveys/230446645"
    },
    {
      "id": "230500260",
      "title": "Data feed from Common Platform into Claim for Crown Court Defence - feedback survey",
      "nickname": "",
      "href": "https://api.eu.surveymonkey.com/v3/surveys/230500260"
    },
    ...
  ],
  "per_page": 50,
  "page": 1,
  "total": 11,
  "links": {
    "self": "https://api.eu.surveymonkey.com/v3/surveys?per_page=50&page=1"
  }
}
```

This id in the `data` section corresponding to the correct survey is used in
the requests to fetch collector id and question ids below.

### Collector id

One or more collector ids are set up for each survey and this can be used to
separate submissions to the same survey from different sources, such a the
production and development environments. To find the list of all collectors for
a survey:

```sh
curl --request GET \
     --url https://api.eu.surveymonkey.com/v3/surveys/<survey id>/collectors \
     --header 'Accept: application/json' \
     --header 'Authorization: Bearer <access token>' \
     | jq
```

This will return data like:

```json
{
  "data": [
    {
      "name": "Embedded Survey 1",
      "id": "330288407",
      "href": "https://api.eu.surveymonkey.com/v3/collectors/330288407",
      "type": "popup"
    },
    ...
  ],
  "per_page": 50,
  "page": 1,
  "total": 3,
  "links": {
    "self": "https://api.eu.surveymonkey.com/v3/surveys/230446645/collectors?per_page=50&page=1"
  }
}
```

The collector is registered with the SurveyMonkey module with:

```ruby
config.register_collector(:feedback, id: <collector id>)
```

and then the label given to the collector (e.g. `:feedback`) is set as the
`collector` attribute for the form page class.

See:
* `config/initializers/survey_monkey.rb`
* `app/forms/feedback_form.rb`

### Question ids

The question ids for a survey can be found from the details of the survey:

```sh
curl --request GET \
     --url https://api.eu.surveymonkey.com/v3/surveys/<survey id>/details \
     --header 'Accept: application/json' \
     --header 'Authorization: Bearer <access token>' \
     | jq
```

This will return data like:

```json
{
  "title": "Claim for Crown Court Defence Feedback",
  ...
  "pages": [
    {
      "title": "",
      "description": "",
      "position": 1,
      "question_count": 5,
      "id": "26019002",
      "href": "https://api.eu.surveymonkey.com/v3/surveys/230446645/pages/26019002",
      "questions": [
        {
          "id": "62469808",
          "position": 1,
          "visible": true,
          "family": "single_choice",
          "subtype": "vertical",
          "layout": null,
          "sorting": null,
          "required": null,
          "validation": null,
          "forced_ranking": false,
          "headings": [
            {
              "heading": "Were you able to complete the tasks you aimed to on Claim for Crown Court defence today?"
            }
          ],
          "href": "https://api.eu.surveymonkey.com/v3/surveys/230446645/pages/26019002/questions/62469808",
          "answers": {
            "choices": [
              {
                "position": 1,
                "visible": true,
                "text": "Yes",
                "quiz_options": {
                  "score": 0
                },
                "id": "519552297"
              },
              {
                "position": 2,
                "visible": true,
                "text": "No",
                "quiz_options": {
                  "score": 0
                },
                "id": "519552298"
              },
              {
                "position": 3,
                "visible": true,
                "text": "Partially",
                "quiz_options": {
                  "score": 0
                },
                "id": "519552299"
              }
            ]
          }
        },
        {
          "id": "62479509",
          "position": 2,
          "visible": true,
          "family": "presentation",
          "subtype": "descriptive_text",
          "layout": null,
          "sorting": null,
          "required": null,
          "validation": null,
          "forced_ranking": false,
          "headings": [
            {
              "heading": "If you have found a fault or bug, please <a href=\"https://claim-crown-court-defence.service.gov.uk/feedback/new?type=bug_report\" rel=\"nofollow\" target=\"_blank\">report it here (opens in a new window)</a>"
            }
          ],
          "nickname": "Text1",
          "href": "https://api.eu.surveymonkey.com/v3/surveys/230446645/pages/26019002/questions/62479509",
          "display_options": {
            "show_display_number": false
          }
        },
        ...
      ]
    }
  ]
}
```

This contains question ids as well as option ids, as appropriate. These ids
need to be added to the correct form page class. See, for example,
`app/forms/feedback_form.rb`.
