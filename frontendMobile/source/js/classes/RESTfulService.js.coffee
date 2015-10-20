class window.RESTfulService
  # @URL = 'http://10.20.20.69'
  @URL = 'http://ec2-54-68-79-250.us-west-2.compute.amazonaws.com:3000'
  @makeRequest: (method, url, data, callback) ->
    $.ajax({
        method: method,
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        data: if method is 'GET' then $.param(data) else JSON.stringify(data),
        url: @URL + url,
        success: ((data, status, xhr) ->
                  headers = 
                    accessToken: xhr.getResponseHeader('access-token')
                    client: xhr.getResponseHeader('client')
                    uid: xhr.getResponseHeader('uid')
                  console.log headers
                  callback(null, data, headers)),
        error: ((data) ->
                  callback(data, null, null)),
        beforeSend: (xhr) ->
          if !!Config.getItem('headers')
            headers = JSON.parse(Config.getItem('headers'))
            xhr.setRequestHeader('access-token', headers.accessToken)
            xhr.setRequestHeader('client', headers.client)
            xhr.setRequestHeader('uid', headers.uid)
          xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8')          
          xhr.withCredentials = true
      })