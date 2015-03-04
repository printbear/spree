#= require jsuri
class window.Spree
  @ready: (callback) ->
    jQuery(document).ready(callback)

  # Helper function to take a URL and add query parameters to it
  # Uses the JSUri library from here: https://code.google.com/p/jsuri/
  # Thanks to Jake Moffat for the suggestion: https://twitter.com/jakeonrails/statuses/321776992221544449
  @url: (uri, query) ->
    if Spree.env == 'development'
      console.warn 'Spree.url is deprecated, please use Spree.ajax for your request instead.'
    if uri.path == undefined
      uri = new Uri(uri)
    if query
      $.each query, (key, value) ->
        uri.addQueryParam(key, value)
    if Spree.api_key
      uri.addQueryParam('token', Spree.api_key)
    return uri

  # Helper method in case people want to call uri rather than url
  @uri: (uri, query) ->
    url(uri, query)

  # These functions (Spree.ajax, Spree.getJSON) automatically add the token as a request header.
  #
  # Spree.ajax works in two ways to support common jQuery syntax:
  #
  # Spree.ajax("url", {settings: 'go here'})
  # or:
  # Spree.ajax({url: "url", settings: 'go here'})
  #
  # Spree.getJSON has the same method signature as $.getJSON
  @ajax: (url_or_settings, settings) ->
    url = undefined
    options = undefined
    if (typeof(url_or_settings) == "string")
      url = url_or_settings
      options = settings
    else
      url = url_or_settings['url']
      delete url_or_settings['url']
      options = url_or_settings

    options = $.extend(options, { headers: { "X-Spree-Token": Spree.api_key } })
    $.ajax(url, options)

  @getJSON: (url, data, success) ->
    if typeof data is 'function'
      success = data
      data = undefined
    @ajax(
      dataType: "json",
      url: url,
      data: data,
      success: success
    )
