class AddDiscountToAllUser < ActiveRecord::Migration
  def change
    users = Class.new(ActiveRecord::Base) {
      self.table_name = :users
    }

    users.all.each do |user| 
      user.discount =  15000
      user.save
    end
  end
end
