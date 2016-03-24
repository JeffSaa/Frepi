class AddSizeAndDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :size, :string
    add_column :products, :description, :text
  end
end
