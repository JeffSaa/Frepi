class LoadingVM
  constructor: ->   
    setTimeout((->
        if Config.getItem('user')
          data = 
            email: Encryptor.decrypt(Config.getItem('user'), 'myKey')
            password: Encryptor.decrypt(Config.getItem('pass'), 'myKey')

          RESTfulService.makeRequest('POST', '/auth/sign_in', data, (error, success, headers) =>
            if error
              alert('An error has ocurred in the authentication.')
              # window.location.href = '../../login.html'
            else
              encryptedClient = Encryptor.encrypt(headers.client, 'myKey')
              encryptedToken = Encryptor.encrypt(headers.accessToken, 'myKey')
              Config.setItem('accessToken', encryptedToken)
              Config.setItem('client', encryptedClient)
              Config.setItem('uid', headers.uid)
              if success.data.user_type is 'user'
                window.location.href = '../../store.html'
              else
                window.location.href = '../../admin.html'
          )
        else
          window.location.href = '../../login.html'

    ), 1500)        

loading = new LoadingVM