class Bill < ActiveRecord::Base
  # Relationship
  belongs_to :business
end
