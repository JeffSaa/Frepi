if Rails.env.development?

  # Store Partners
  2.times do |_|
  StorePartner.create!( nit: Faker::Company.duns_number, manager_name: Faker::Name.name,
                        manager_email: Faker::Internet.email, manager_phone_number: Faker::Number.number(10),
                        store_name: Faker::Company.name)
  end

  # Sucursals
  3.times do |_|
  store_partner = StorePartner.find([1, 2].sample)
  store_partner.sucursals.create!( name: Faker::Company.name, manager_full_name: Faker::Name.name, manager_email: Faker::Internet.email,
                                  manager_phone_number: Faker::Number.number(10), phone_number: Faker::Number.number(7),
                                  address: Faker::Address.street_address, latitude: Faker::Address.latitude,
                                  longitude: Faker::Address.longitude)
  end


  # Products
  30.times do |_|
    sucursal = Sucursal.find([1, 2, 3].sample)
    sucursal.products.create!(reference_code: Faker::Company.duns_number, name: Faker::Commerce.product_name,
                              store_price: Faker::Commerce.price, frepi_price: Faker::Commerce.price, image: Faker::Company.logo)
  end


  # Users
  10.times do |_|
    User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name, email: Faker::Internet.email,
                  identification: Faker::Code.ean, address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                  image: Faker::Avatar.image)
  end

  # Orders
=begin
  5.times do |_|
    user = User.find(Faker::Number.between(0, 9))
    user.order.create!( active: [true, false].sample, status: [:received, :delivering, :dispatched].sample,
                         approximate_delivery_date: Faker::Time.forward(20)
                        )
  end
=end
  # Complaints
  5.times do |_|
    user = User.find(Faker::Number.between(1, 10))
    user.complaints.create!(subject: Faker::Name.title, message: Faker::Lorem.paragraph)
  end

end