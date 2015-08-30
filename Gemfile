source 'https://rubygems.org'
ruby '2.2.2'

gem 'rails', '4.2.3'
gem 'rails-api'


group :development do
  gem 'sqlite3'
  gem 'faker'
  gem 'thin'
end

group :production do
  gem 'puma'
  gem 'pg'
end

# General
gem 'validates_timeliness'
gem 'active_model_serializers'

# Authentication
gem 'devise'
gem 'devise_token_auth' # Token based authentication for Rails JSON APIs
gem 'omniauth' # required for devise_token_auth