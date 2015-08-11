class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :day,          null: false
      t.time   :start_hour,   null: false
      t.time   :end_hour,     null: false

      t.timestamps null: false
    end
  end
end
