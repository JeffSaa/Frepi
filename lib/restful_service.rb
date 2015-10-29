require 'net/http'

module RestfulService

  # TODO: Add API key, URL BASE
  # Constants
  #KEY = 'AIzaSyD-1nxACKtYjr8x0h7kQXYKIBMzKl3vYds'
  #URL_BASE = 'https://maps.googleapis.com/maps/api/distancematrix/json'

  def make_request(params = nil, url = URL_BASE, method = :get)
    params[:key] = KEY
    response = method_http(method, url, params)
    JSON.parse(response)
  end

  private
  def method_http(method, url, params)
    case method
      when :get
        uri = URI(url)
        uri.query = URI.encode_www_form(params)
        Net::HTTP.get_response(uri).body
      when :post
        Net::HTTP.post_form(URI.parse(url), params).body
    end
  end

  module_function :make_request
end