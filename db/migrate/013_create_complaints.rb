class CreateComplaints < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.string  :message,     null: false
      t.string  :subject,     null: false

      # Association
      t.references  :user, null: false, index: true

      t.timestamps null: false
    end
  end
end
