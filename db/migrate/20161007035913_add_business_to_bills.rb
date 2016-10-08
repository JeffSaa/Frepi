class AddBusinessToBills < ActiveRecord::Migration
  def change
    add_reference :bills, :business, index: true, foreign_key: true
  end
end
