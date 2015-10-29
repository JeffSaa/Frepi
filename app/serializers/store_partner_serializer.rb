class StorePartnerSerializer < ActiveModel::Serializer
  attributes :id, :nit, :name, :logo, :description, :created_at, :updated_at
  has_many :sucursals
end
