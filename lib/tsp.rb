require 'genetic_algorithm.rb'

module TSP

  include  GeneticAlgorithm

  def route_shortest(elements, origin_latitude, origin_longitude)
    matrix = distance_matrix(elements,origin_latitude, origin_longitude)
    matrix.each do |x|
      p x.map { |e|  e.to_f }
    end
  end

  # ----------- private ------------#
  private

  def distance_matrix(elements, origin_latitude, origin_longitude)
    distances_from_origin = []
    matrix = []

    elements.each do |element|
      distances_from_origin << element.distance_to([origin_latitude, origin_longitude])
      columns = []
      elements.each do |destination|
        to_find = [element.id, destination.id]
        element == destination ? columns <<  0 : columns << Distance.where(sucursal_id: to_find, destination_id: to_find).pluck(:distance).first
      end
      matrix << columns
    end

    distances_from_origin.insert(0, 0)
    matrix.enum_for(:each_with_index).map { |row, index| row.insert(0, distances_from_origin[index + 1]) }
    matrix.insert(0, distances_from_origin)
    matrix
  end

  module_function :route_shortest
end