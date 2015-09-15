# Obligatory Data
country = Country.create!(name: 'colombia')
state = country.states.create!(name: 'atlantico')
city = state.cities.create!(name: 'barranquilla')

# email: admin@frepi.com
# Password: frepi123

if Rails.env.development?

  # Constant
  DAY = %w(monday tuesday wednesday thursday friday saturday sunday)

  # Store Partners
  2.times do |_|
    StorePartner.create!(nit: Faker::Company.duns_number, name: Faker::Company.name, logo: Faker::Company.logo, description: Faker::Lorem.sentence)
  end

  # Sucursals
  3.times do |_|
    store_partner = StorePartner.find([1, 2].sample)
    store_partner.sucursals.create!(name: Faker::Company.name, manager_full_name: Faker::Name.name,
                                    manager_email: Faker::Internet.email, manager_phone_number: Faker::Number.number(10),
                                    phone_number: Faker::Number.number(7), address: Faker::Address.street_address,
                                    latitude: Faker::Address.latitude, longitude: Faker::Address.longitude)
  end

  5.times do |_|
    # Categories
    Category.create!(name: Faker::Commerce.department(1), description: Faker::Lorem.sentence)
  end

  15.times do |_|
    # Subcategories
    category = Category.find(Faker::Number.between(1, 5))
    subcategory = category.subcategories.new(name: Faker::Commerce.department(1))
    until subcategory.valid?
      subcategory = category.subcategories.new(name: Faker::Commerce.department(1))
    end
    subcategory.save!
  end

  # Products
  300.times do |_|
    sucursal = Sucursal.find([1, 2, 3].sample)
    subcategory = Subcategory.find(Faker::Number.between(1, 15))
    sucursal.products.save(reference_code: Faker::Company.duns_number, name: Faker::Commerce.product_name,
                           store_price: Faker::Commerce.price, frepi_price: Faker::Commerce.price, image: Faker::Avatar.image(nil, "960x800"),
                           subcategory_id: subcategory.id, available: [true, false].sample)
  end

  # Default User Frepi Admin
  User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name,
                email: 'admin@frepi.com', identification: Faker::Code.ean,
                address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                image: Faker::Avatar.image, city_id: city.id, latitude: Faker::Address.latitude,
                longitude: Faker::Address.longitude, user_type: 'administrator',
                password: 'frepi123', password_confirmation: 'frepi123')

  # Default User Client
  User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name,
                email: 'client@frepi.com', identification: Faker::Code.ean,
                address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                image: Faker::Avatar.image, city_id: city.id, latitude: Faker::Address.latitude,
                longitude: Faker::Address.longitude, user_type: 'user',
                password: 'frepi123', password_confirmation: 'frepi123')


  # Users random
  9.times do |_|
    password = Faker::Internet.password(6)
    User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name,
                  email: Faker::Internet.email, identification: Faker::Code.ean,
                  address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                  image: Faker::Avatar.image, city_id: city.id, latitude: Faker::Address.latitude,
                  longitude: Faker::Address.longitude, user_type: %w(user administrator).sample,
                  password: password, password_confirmation: password)
  end

  # Orders
  10.times do |item|
    user = User.find(Faker::Number.between(1, 10))
    sucursal = Sucursal.find(Sucursal.find([1, 2, 3].sample))
    order = user.orders.create!(active: [true, false].sample, status: %w(received delivering dispatched).sample,
                                sucursal_id: sucursal.id, date: Faker::Time.backward(3))
    #order.products << Product.find(item + 1)
    quantity = Faker::Number.between(1, 10)
    item = order.orders_products.create!(product_id: Product.find(item + 1).id, quantity: quantity)
  end

  # Complaints
  5.times do |_|
    user = User.find(Faker::Number.between(1, 10))
    user.complaints.create!(subject: Faker::Name.title, message: Faker::Lorem.paragraph)
  end

  # Shoppers
  5.times do |_|
    Shopper.create!(name: Faker::Name.name, last_name: Faker::Name.last_name,
                    identification: Faker::Code.ean, address: Faker::Address.street_address,
                    phone_number: Faker::PhoneNumber.cell_phone, image_url: Faker::Avatar.image,
                    company_email: Faker::Internet.email, personal_email: Faker::Internet.email,
                    status: :active)
  end

  # Orders accepted by a shopper
  5.times do |id|
    id = id + 1
    shopper = Shopper.find(id)
    shopper.shoppers_orders.create!(order_id: Order.find(id).id, accepted_date: Faker::Date.forward(id))
  end

  # Orders with schedules
  4.times do |order_id|
    order_id = Faker::Number.between(1, 5)
    order = Order.find(order_id)
    order.schedules.create!(day: DAY.sample, start_hour: Time.now, end_hour: Time.now + 3.hour)
  end

  # Shopper with Schedules
  5.times do |shopper_id|
    shopper = Shopper.find(shopper_id + 1)
    shopper.schedules.create!( day: DAY.sample, start_hour: Time.now, end_hour: Time.now + 2.hour)
  end
end