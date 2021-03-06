Feature:
  As cucumber tester
  I want to use REST steps

  Background:
    Given the following items exist:
      | uid  |
      | test |

  Scenario:
    Given the client provides the header "Accept: application/hal+json"
    When the client does a GET request to "/item/test"
    Then the status code should be "200" (OK)
    Then the response should contain the header "Content-Type" with value "application/hal+json"
    And the response should be HAL/JSON:
      """json
      {
        "_links": {
          "self": {
            "href": "https://example.org/item/test"
          }
        },
        "id": 1,
        "uid": "test"
      }
      """

  Scenario:
    Given the client provides the header "Accept: application/hal+json"
    When the client does 10 concurrent GET requests to "/item/test"
    Then all requests should have succeeded
