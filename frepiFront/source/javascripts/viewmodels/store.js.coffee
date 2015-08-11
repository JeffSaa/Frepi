class LoginVM
  constructor: ->
    @categories = ko.observableArray([
        {
          name: 'Populares',
          products: [
            {
              name: 'Arroz Marca O',
              price: '2000 x lb',
              subCategory: 'Granos'
            }
            {
              name: 'Granola Olímpica',
              price: '5000 x und',
              subCategory: 'Cereales'
            }
            {
              name: 'Pan fránces',
              price: '3000 x und',
              subCategory: 'Panadería'
            }
          ]
        }
        {
          name: 'Frutas & Verduras',
          products: [
            {
              name: 'Yuca',
              price: '600 x lb',
              subCategory: 'Tubérculos'
            }
            {
              name: 'Ñame',
              price: '1400 x lb',
              subCategory: 'Tubérculos'
            }
            {
              name: 'Fresa',
              price: '2000 x lb',
              subCategory: 'Frutas'
            }
          ]
        }
      ])


login = new LoginVM
ko.applyBindings(login)