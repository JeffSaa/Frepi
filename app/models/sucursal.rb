class Sucursal < ActiveRecord::Base

  # Associations
  belongs_to :store_partner
  has_many   :sucursals_products
  has_many   :orders
  has_many   :distances,          dependent: :delete_all
  has_many   :products,           through: :sucursals_products
  has_many   :subcategories,      through: :products
  has_many   :categories,         through: :subcategories

  # Validations
  validates :store_partner, :name, :address, presence: true
  validates :latitude, :longitude, numericality: true, allow_nil: true
  validates :name, uniqueness: { scope: :store_partner_id }

  # Geocode
  #reverse_geocoded_by :latitude, :longitude

  # Callbacks
  #before_update :recalculate_distances
  #after_destroy :destroy_relations
  #after_create  :set_distances

  # Methods
  private
  def set_distances
    sucursals = Sucursal.all[0..-2]
    if sucursals.size > 0
      sucursals.each do |sucursal|
        # Distances is fetched on miles
        distance = self.distance_to([sucursal.latitude, sucursal.longitude])
        Distance.create!(sucursal_id: self.id, destination_id: sucursal.id, distance: distance)
      end
    end
  end

  def destroy_relations
    self.distances.destroy_all
    Distance.where(destination_id: self.id).map { |element| element.destroy }
  end

  def recalculate_distances
    unless self.latitude_was == self.latitude && self.longitude_was == self.longitude
      destroy_relations
      set_distances
    end
  end

end
