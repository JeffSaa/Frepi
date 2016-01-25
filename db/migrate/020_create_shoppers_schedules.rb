class CreateShoppersSchedules < ActiveRecord::Migration
  def change
    create_table :shoppers_schedules do |t|
      t.references :shopper,  index: true, null: false
      t.references :schedule, index: true, null: false

      t.timestamps null: false
    end
  end
end
