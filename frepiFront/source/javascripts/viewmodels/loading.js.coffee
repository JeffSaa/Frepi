class LoadingVM
  constructor: ->   
    @shouldShowError = ko.observable(false)
    setTimeout((=>
      @checkSession()
    ), 1000)

  checkSession: ->
    if Config.getItem('uid')
      if Config.getItem('pass')
        data = 
          email: Config.getItem('user')
          password: Config.getItem('pass')

        RESTfulService.makeRequest('POST', '/auth/sign_in', data, (error, success, headers) =>
          if error
            # alert('An error has ocurred in the authentication. Check your network conection.')
            @shouldShowError = ko.observable(true)
            # window.location.href = '../login.html'
          else
            Config.setItem('accessToken', headers.accessToken)
            Config.setItem('client', headers.client)
            if success.data.user_type is 'user'
              window.location.href = '../store.html'
            else
              window.location.href = '../admin.html'
        )
      else
        data = 
          uid: Config.getItem('uid')
        alert('Authenticating with FB user saved in localStorage.')
        RESTfulService.makeRequest('POST', '/auth/facebook/callback', data, (error, success, headers) =>
          if error
            # alert('An error has ocurred in the authentication. Check your network conection.')
            @shouldShowError = ko.observable(true)
            # window.location.href = '../login.html'
          else
            Config.setItem('accessToken', headers.accessToken)
            Config.setItem('client', headers.client)
            if success.user.userType is 'user'
              window.location.href = '../store.html'
            else
              window.location.href = '../admin.html'
        )
    else
      window.location.href = '../login.html'

loading = new LoadingVM
ko.applyBindings(loading)