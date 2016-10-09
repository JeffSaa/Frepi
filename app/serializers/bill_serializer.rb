class BillSerializer < ActiveModel::Serializer
  attributes :id

  # Relationship
  belongs_to :business
  belongs_to :user
end
