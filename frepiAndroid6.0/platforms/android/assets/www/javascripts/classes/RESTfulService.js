(function() {
  window.RESTfulService = (function() {
    function RESTfulService() {}

    RESTfulService.URL = 'http://ec2-54-68-79-250.us-west-2.compute.amazonaws.com:8080/api/v1';

    RESTfulService.makeRequest = function(method, url, data, callback) {
      return $.ajax({
        method: method,
        dataType: 'json',
        contentType: 'application/json; charset=UTF-8',
        data: method === 'GET' ? $.param(data) : JSON.stringify(data),
        url: this.URL + url,
        success: (function(data, status, xhr) {
          var headers;
          headers = {
            accessToken: xhr.getResponseHeader('access-token'),
            totalItems: xhr.getResponseHeader('Total-Count'),
            client: xhr.getResponseHeader('client'),
            link: xhr.getResponseHeader('Link'),
            uid: xhr.getResponseHeader('uid')
          };
          return callback(null, data, headers);
        }),
        error: (function(data) {
          return callback(data, null, null);
        }),
        beforeSend: function(xhr) {
          var headers;
          if (!!Config.getItem('headers')) {
            headers = JSON.parse(Config.getItem('headers'));
            xhr.setRequestHeader('access-token', headers.accessToken);
            xhr.setRequestHeader('client', headers.client);
            xhr.setRequestHeader('uid', headers.uid);
          }
          xhr.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
          return xhr.withCredentials = true;
        }
      });
    };

    return RESTfulService;

  })();

}).call(this);
