# frozen_string_literal: true

# rubocop:disable Metrics/LineLength

# * When the client does a GET request to the "items" resource
#
When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource$/) do |method, resource|
  step %(the client does a #{method} request to the "#{resource}" resource with these template variables:), table([[]])
end

# * When the client does a GET request to the "item" resource with the template variable "item_uid" set to "hello"
#
When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource with the template variable "([^"]*)" set to "([^"]*)"$/) do |method, resource, key, value|
  tables = [%w[key value], [key, value]]

  step %(the client does a #{method} request to the "#{resource}" resource with these template variables:), table(tables)
end

# * When the client does a GET request to the "item" resource with these template variables:
#     | key      | value       |
#     | item_uid | hello       |
#     | user_uid | bartsimpson |
#
When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource with these template variables:$/) do |method, resource, table|
  params = {}
  table && table.hashes.each do |row|
    params[row['key']] = row['value']
  end

  api = HyperResource.from_body(api_body)
  url = api.send(resource, params).href
  step %(the client does a #{method} request to "#{url}")
end

# * When the client does a POST request to the "items" resource with the following content:
#     """json
#     {
#       "uid": "hello",
#       "price": 100
#     }
#     """
#
When(/^the client does a (GET|POST|DELETE) request to the "([^"]*)" resource with the following content:$/) do |method, resource, content|
  api  = HyperResource.from_body(api_body)
  url  = api.send(resource, {}).href

  step %(the client does a #{method} request to "#{url}" with the following content:), content
end

# * When the client does a PUT request to the "item" resource with the template variable "item_uid" set to "hello" and the following content:
#     """json
#     {
#       "price": 10
#     }
#     """
#
When(/^the client does a (POST|PUT) request to the "([^"]*)" resource with the template variable "([^"]*)" set to "([^"]*)" and the following content:$/) do |method, resource, key, value, content|
  api  = HyperResource.from_body(api_body)
  url  = api.send(resource, key => value).href

  step %(the client does a #{method} request to "#{url}" with the following content:), content
end

# * When the client does a POST request to the "user_item_preference" resource with the template variable "user_id" set to "bartsimpson" and the template variable "item_id" set to "bnl-telegraaf-20130212-1" and the following content:
#   """json
#   {
#     "prefer": "less"
#   }
#   """
#
When(/^the client does a (POST|PUT) request to the "([^"]*)" resource with the template variable "([^"]*)" set to "([^"]*)" and the template variable "([^"]*)" set to "([^"]*)" and the following content:$/) do |method, resource, key, value, key2, value2, content|
  api  = HyperResource.from_body(api_body)
  url  = api.send(resource, key => value, key2 => value2).href

  step %(the client does a #{method} request to "#{url}" with the following content:), content
end

def api_body
  current_accept_header = current_session.instance_variable_get(:@headers)['Accept']

  step %(the client provides the header "Accept: application/hal+json")
  body = JSON.parse(get('/api').body)

  if current_accept_header
    step %(the client provides the header "Accept: #{current_accept_header}")
  else
    header('Accept', nil)
  end

  body
end
