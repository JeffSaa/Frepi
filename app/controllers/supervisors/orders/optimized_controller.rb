require 'tsp.rb'

class Supervisors::Orders::OptimizedController < ApplicationController
  skip_before_action :authenticate_user!, :require_administrator, :authenticate_supervisor!
  include TSP

  def create
    route_shortest([Sucursal.find(1),Sucursal.find(2),Sucursal.find(3)], 23, -34)
  end
end
