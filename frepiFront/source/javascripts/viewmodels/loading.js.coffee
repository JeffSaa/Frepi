class LoadingVM
  constructor: ->   
    setTimeout((->
        if Config.getItem('user')
          data = 
            email: Encryptor.decrypt(Config.getItem('user'), 'myKey')
            password: Encryptor.decrypt(Config.getItem('pass'), 'myKey')

          RESTfulService.makeRequest('POST', '/auth/sign_in', data, (error, success) =>
            if error
              console.log 'An error has ocurred in the authentication.'
              window.location.href = '../../login.html'
            else
              encryptedClient = Encryptor.encrypt(success.client, 'myKey')
              encryptedToken = Encryptor.encrypt(success.accessToken, 'myKey')
              Config.setItem('accessToken', encryptedToken)
              Config.setItem('client', encryptedClient)
              Config.setItem('uid', success.uid)
              window.location.href = '../../store.html'
          )
        else
          window.location.href = '../../login.html'

    ), 1500)        

loading = new LoadingVM