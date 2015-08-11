if Rails.env.development?
  # Constant
  DAY = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  # Store Partners
  2.times do |_|
   StorePartner.create!( nit: Faker::Company.duns_number, store_name: Faker::Company.name)
  end

  # Sucursals
  3.times do |_|
  store_partner = StorePartner.find([1, 2].sample)
  store_partner.sucursals.create!( name: Faker::Company.name, manager_full_name: Faker::Name.name, manager_email: Faker::Internet.email,
                                  manager_phone_number: Faker::Number.number(10), phone_number: Faker::Number.number(7),
                                  address: Faker::Address.street_address, latitude: Faker::Address.latitude,
                                  longitude: Faker::Address.longitude)
  end

  5.times do |_|
    # Categories
    Category.create!(name: Faker::Commerce.department(1), description: Faker::Lorem.sentence)
  end

  15.times do |_|
    # Subcategories
    category = Category.find(Faker::Number.between(1, 5))
    category.subcategories.create!(name: Faker::Commerce.department(1))
  end

  # Products
  30.times do |_|
    sucursal = Sucursal.find([1, 2, 3].sample)
    subcategory = Subcategory.find(Faker::Number.between(1, 15))
    sucursal.products.create!(reference_code: Faker::Company.duns_number, name: Faker::Commerce.product_name,
                              store_price: Faker::Commerce.price, frepi_price: Faker::Commerce.price, image: Faker::Company.logo,
                              subcategory_id: subcategory.id)
  end

  # Users
  10.times do |_|
    User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name, email: Faker::Internet.email,
                  identification: Faker::Code.ean, address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                  image: Faker::Avatar.image)
  end

  # Orders
  10.times do |_|
    user = User.find(Faker::Number.between(1, 10))
    sucursal = Sucursal.find(Sucursal.find([1, 2, 3].sample))
    user.orders.create!( active: [true, false].sample, status: [:received, :delivering, :dispatched].sample,
                        approximate_delivery_date: Faker::Time.forward(20), sucursal: sucursal)
  end

  # Complaints
  5.times do |_|
    user = User.find(Faker::Number.between(1, 10))
    user.complaints.create!(subject: Faker::Name.title, message: Faker::Lorem.paragraph)
  end

  # Shoppers
  5.times do |_|
    Shopper.create!(  name: Faker::Name.name, last_name: Faker::Name.last_name,
                      identification: Faker::Code.ean, address: Faker::Address.street_address,
                      phone_number: Faker::PhoneNumber.cell_phone, image_url: Faker::Avatar.image,
                      company_email: Faker::Internet.email, personal_email: Faker::Internet.email,
                      status: :active)
  end

  # Orders accepted by a shopper
  5.times do |id|
    id += 1
    shopper = Shopper.find(id)
    shopper.shoppers_orders.create!(order_id: Order.find(id).id, accepted_date: Faker::Date.forward(1),
                                    delivery_time: Faker::Date.forward(2))
  end

  # Orders with schedules
  4.times do |order_id|
    order_id = Faker::Number.between(1, 10)
    order = Order.find(order_id)
    order.schedules.create!(day: DAY.sample, start_hour: Time.now, end_hour: Time.now + Faker::Number.between(30, 120).minutes)
  end

  # Shopper with Schedules
  5.times do |shopper_id|
    shopper = Shopper.find(shopper_id + 1)
    shopper.schedules.create!( day: DAY.sample, start_hour: Faker::Time.between(2.days.ago, Time.now, :day),
                               end_hour: Faker::Time.between(2.days.ago, Time.now, :night))
  end
end