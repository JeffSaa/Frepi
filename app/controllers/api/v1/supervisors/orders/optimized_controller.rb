require 'tsp.rb'

class  Api::V1::Supervisors::Orders::OptimizedController < Api::V1::ApiController
  skip_before_action :authenticate_user!, :require_administrator, :authenticate_supervisor!
  include TSP

  def create
    route_shortest([Sucursal.find(1),Sucursal.find(2),Sucursal.find(3)], 23, -34)
  end
end
