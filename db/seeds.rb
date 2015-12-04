# Obligatory Data
country = Country.create!(name: 'colombia')
state = country.states.create!(name: 'atlantico')
city = state.cities.create!(name: 'barranquilla')

# email: admin@frepi.com | client@frepi.com | supervisor@frepi.com
# Password: frepi123

if Rails.env.development?
  PASSWORD =  'frepi123'
  EMAILS = %w(admin@frepi.com client@frepi.com supervisor@frepi.com in-store-shopper@gmail.com delivery-shopper@gmail.com)

  # Store Partners
  StorePartner.create!(nit: Faker::Company.duns_number, name: Faker::Company.name, logo: Faker::Company.logo, description: Faker::Lorem.sentence)

  # ---------------------------------- ROLES ----------------------------------- #

  # --- Default Frepi Admin --- #
  User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name,
                email: EMAILS[0], identification: Faker::Code.ean,
                address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                image: Faker::Avatar.image, city_id: city.id, latitude: Faker::Address.latitude,
                longitude: Faker::Address.longitude, administrator: true,
                password: PASSWORD, password_confirmation: PASSWORD)

  # ---- Default Client --- #
  User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name,
                email: EMAILS[1], identification: Faker::Code.ean,
                address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                image: Faker::Avatar.image, city_id: city.id, latitude: Faker::Address.latitude,
                longitude: Faker::Address.longitude, password: PASSWORD, password_confirmation: PASSWORD)


  # --- Defult Supervisors --- #
  Supervisor.create!( first_name: Faker::Name.name, last_name: Faker::Name.last_name,
                      identification: Faker::Code.ean, address: Faker::Address.street_address,
                      phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                      email: EMAILS[2], city_id: city.id, password: PASSWORD,
                      password_confirmation: PASSWORD)


  # --- Defult IN-STORE Shopper --- #
  Shopper.create!(first_name: Faker::Name.name, last_name: Faker::Name.last_name,
                  identification: Faker::Code.ean, address: Faker::Address.street_address,
                  phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                  email: EMAILS[3], status: Shopper::STATUS[0], city_id: city.id,
                  shopper_type: Shopper::TYPES[0])


  # --- Defult DELIVERY Shopper --- #
  Shopper.create!(first_name: Faker::Name.name, last_name: Faker::Name.last_name,
                  identification: Faker::Code.ean, address: Faker::Address.street_address,
                  phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                  email: EMAILS[4], status: Shopper::STATUS[0], city_id: city.id,
                  shopper_type: Shopper::TYPES[1])


  # --- Users random --- #
  10.times do |_|
    User.create!( name: Faker::Name.name, last_name: Faker::Name.last_name,
                  email: Faker::Internet.email, identification: Faker::Code.ean,
                  address: Faker::Address.street_address, phone_number: Faker::PhoneNumber.cell_phone,
                  image: Faker::Avatar.image, city_id: city.id, latitude: Faker::Address.latitude,
                  longitude: Faker::Address.longitude,
                  password: PASSWORD, password_confirmation: PASSWORD)
  end


  # --- Supervisors Random --- #
  3.times do |_|
    Supervisor.create!(first_name: Faker::Name.name, last_name: Faker::Name.last_name,
                      identification: Faker::Code.ean, address: Faker::Address.street_address,
                      phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                      company_email: Faker::Internet.email, email: Faker::Internet.email,
                      password: PASSWORD, password_confirmation: PASSWORD,
                      city_id: city.id)

  end


  # --- Shoppers Random --- #
  3.times do |_|
    Shopper.create!(first_name: Faker::Name.name, last_name: Faker::Name.last_name,
                    identification: Faker::Code.ean, address: Faker::Address.street_address,
                    phone_number: Faker::PhoneNumber.cell_phone, image: Faker::Avatar.image,
                    email: Faker::Internet.email, status: Shopper::STATUS[0],
                    shopper_type: Shopper::TYPES.sample)
  end

  # ------------------------------ FREPI CORE  ----------------------------------- #

  # Sucursals
  3.times do |_|
    store_partner = StorePartner.first
    store_partner.sucursals.create!(name: Faker::Company.name, manager_full_name: Faker::Name.name,
                                    manager_email: Faker::Internet.email, manager_phone_number: Faker::Number.number(10),
                                    phone_number: Faker::Number.number(7), address: Faker::Address.street_address,
                                    latitude: Faker::Address.latitude, longitude: Faker::Address.longitude)
  end

  # Categories
  5.times do |_|
    Category.create!(name: Faker::Commerce.department(1), description: Faker::Lorem.sentence, store_partner_id: StorePartner.first.id)
  end

  # Subcategories
  10.times do |_|
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
    subcategory = Subcategory.find(Faker::Number.between(1, 10))
    valid = false
    until valid
      product = sucursal.products.create(reference_code: Faker::Company.duns_number, name: Faker::Commerce.product_name,
                                         store_price: Faker::Commerce.price, frepi_price: Faker::Commerce.price,
                                         image: Faker::Avatar.image(nil, "960x800"),
                                         subcategory_id: subcategory.id, available: true)
      valid = product.valid?
      product.save
    end

  end


  # ---------------------------------- ACTIONS ------------------------------------ #

  # Orders
  15.times do |item|
    user = User.find(Faker::Number.between(1, 10))
    arrival_time =  Faker::Time.forward(3, :morning)

    extra_attributes = {}

    if item >= 12
      extra_attributes = { comment: Faker::Lorem.sentence, address: "#{Faker::Address.street_address} #{Faker::Address.secondary_address}" }
    elsif item >= 9
      extra_attributes = { comment: Faker::Lorem.sentence }
    elsif item > 3
      extra_attributes = { address: "#{Faker::Address.street_address} #{Faker::Address.secondary_address}" }
    end

    attributes = { active: true, status: 0, total_price: Faker::Commerce.price,
                   arrival_time: arrival_time.to_formatted_s(:time), expiry_time: (arrival_time + 2.hours).to_formatted_s(:time),
                   scheduled_date: arrival_time }.merge(extra_attributes)

    order = user.orders.create!(attributes)
    products =  {}
    products[:products] = []

    (1..30).to_a.sample.times do |i|
      quantity = Faker::Number.between(1, 10)
      products[:products] << { id: Faker::Number.between(1, 300), quantity: quantity, comment: Faker::Lorem.sentence }
      #order.orders_products.create!(product_id: Product.find(Faker::Number.between(1, 300)).id, quantity: quantity, comment: Faker::Lorem.sentence)
    end
    order.buy(user, products[:products]).save
  end

  # Complaints
  5.times do |_|
    user = User.find(Faker::Number.between(1, 10))
    user.complaints.create!(subject: Faker::Name.title, message: Faker::Lorem.paragraph)
  end

  # Orders accepted by a shopper
  5.times do |id|
    id = id + 1
    shopper = Shopper.where(shopper_type: 'IN-STORE').sample
    order = shopper.shoppers_orders.create!(order_id: Order.find(id).id, accepted_date: Faker::Date.forward(id))
    order = Order.find(id)
    order.status = 1
    order.save
  end

  # Orders with schedules
  4.times do |order_id|
    order_id = Faker::Number.between(1, 5)
    order = Order.find(order_id)
    order.schedules.create!(day: Schedule::DAY.sample, start_hour: Time.now, end_hour: Time.now + 3.hour)
  end

  # Shopper with Schedules
  5.times do |shopper_id|
    shopper = Shopper.find(shopper_id + 1)
    shopper.schedules.create!( day: Schedule::DAY.sample, start_hour: Time.now, end_hour: Time.now + 2.hour)
  end
end