class StatisticsSerializer < ActiveModel::Serializer
  ]

  has_one :product

  def product
    object
  end

end
