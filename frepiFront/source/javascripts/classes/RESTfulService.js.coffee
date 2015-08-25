class window.RESTfulService
  # @URL = 'http://10.20.20.69'
  @URL = 'http://ec2-54-68-79-250.us-west-2.compute.amazonaws.com:3000'
  @makeRequest: (method, url, data, callback) ->
    $.ajax({
        method: method,
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        data: if method is 'POST' or method is 'PUT' then (JSON.stringify(data)) else "",
        url: @URL + url,
        success: ((data, status, xhr) ->
                  data.accessToken = xhr.getResponseHeader('access-token')
                  data.client = xhr.getResponseHeader('client')
                  data.uid = xhr.getResponseHeader('uid')
                  callback(null, data)),
        error: ((data) ->
                  callback(data, null)),
        beforeSend: (xhr) ->
         xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8')
         # xhr.setRequestHeader('access-token', Config.getItem('token'))
         # xhr.setRequestHeader('client', Config.getItem('client'))
         # xhr.setRequestHeader('uid', Config.getItem('uid'))
         xhr.withCredentials = true
      })