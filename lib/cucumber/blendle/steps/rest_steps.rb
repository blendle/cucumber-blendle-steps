# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

require 'halidator'
require 'rack/utils'

# * When the client does a GET request to "/items"
#
When(/^the client does a GET request to "([^"]*)"$/) do |path|
  get(path, {}, {})
end

# * When the client provides the header "Accept: application/hal+json"
#
When(/^the client provides the header ["'](.*?)["']$/) do |header|
  name, value = header.split(/\s*:\s*/)
  header(name, value)
end

# * When the client does a DELETE request to "/item/hello"
#
When(/^the client does a (POST|DELETE) request to "([^"]*)"$/) do |method, path|
  send(method.downcase, path, {})
end

# * When the client does a POST request to "/items" with the following content:
#   """json
#   {
#     "uid": "hello",
#     "price": 100
#   }
#   """
#
When(/^the client does a (POST|PUT) request to "([^"]*)" with the following content:$/) do |method, path, content|
  send(method.downcase, path, content.strip)
end

# * Then the status code should be "200" (OK)
# * Then the status code should be "204" (No Content)
#
Then(/^the status code should be "(\d+)" \((.+)\)/) do |status_code, status_message|
  assert_equal status_code.to_i, last_response.status, last_response.body
  assert_equal status_message, Rack::Utils::HTTP_STATUS_CODES[status_code.to_i]
end

# * Then the response should contain the header "Location" with value "https://example.org/item/hello"
#
Then(/^the response should contain the header "([^"]*)" with value "([^"]*)"$/) do |header, value|
  assert_equal value, last_response.headers[header]
end

# * Then the response should be of type "application/json" with content:
#     """json
#     {
#       "uid": "hello"
#     }
#     """
#
Then(/^the response should be of type "([^"]*)" with content:$/) do |content_type, content|
  dump last_response.body

  content = Liquid::Template.parse(content).render

  assert_equal content_type, last_response.headers['Content-Type']

  if content_type.include?('json')
    expect(last_response.body).to be_json_eql(content)
  else
    assert_equal content, last_response.body
  end
end

# * Then the response should be JSON:
#     """json
#     {
#       "uid": "hello"
#     }
#     """
Then(/^the response should be JSON:$/) do |content|
  step 'the response should be of type "application/json" with content:', content
end

# * Then the response should be HAL/JSON:
#     """json
#     {
#       "uid": "hello"
#     }
#     """
# * Then the response should be HAL/JSON (disregarding value of "random_id"):
#     """json
#     {
#       "uid": "hello",
#       "random_id": 57303667592
#     }
#     """
#
# NOTE: You can also use Liquid templating in your expectation, which will be
# parsed before validation:
#
#   { "end_date": "{{ 'today' | date }}" } => { "date": "2016-03-15T14:00:00Z" }
#
Then(%r{^the response should be HAL/JSON(?: \(disregarding values? of "([^"]*)"\))?:$}) do |disregard, json|
  step('the response should be HAL/JSON')

  json  = Liquid::Template.parse(json).render
  match = be_json_eql(json)

  if disregard.present?
    disregard.split(',').each do |attribute|
      match = match.excluding(attribute)
    end
  end

  expect(last_response.body).to match
end

# * Then the response contains the "Location" header with value "https://example.org/item/hello"
# * Then the response contains the "Last-Modified" header
#
Then(/^the response contains the "(.*?)" header(?: with value "(.*?)")?$/) do |header, value|
  if value
    assert_equal value, last_response.headers[header]
  else
    assert last_response.headers[header], "missing header: #{header}"
  end
end

# * Then the response at "_embedded/b:subscription-product" should include:
#     """json
#     {
#       "eligible": false
#     }
#     """
Then(/^the response at "(.*)" should include:$/) do |path, json|
  expect(JsonSpec::Helpers.parse_json(last_response.body, path)).to include(JSON.parse(json))
end

Then(%r{^the response should be HAL\/JSON$}) do
  assert_match %r{^application/hal\+json(;.*)?$}, last_response.headers['Content-Type']

  hal = nil
  begin
    hal = Halidator.new(last_response.body, :json_schema)
  rescue JSON::ParserError => e
    assert false, [e.message, last_response.body].join("\n")
  end
  expect(hal).to be_valid, "Halidator errors: #{hal.errors.join(',')}"
end
