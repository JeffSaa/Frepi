class Bill < ActiveRecord::Base
  # Relationship
  belongs_to  :business
  belongs_to  :order
end
