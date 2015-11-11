class CreateSupervisors < ActiveRecord::Migration
  def change
    create_table :supervisors do |t|
      t.references :city,           index: true, foreign_key: true, null: false
      t.string     :identification, null: false
      t.string     :first_name,     null: false
      t.string     :last_name,      null: false
      t.boolean    :active,         null: false, default: true
      t.string     :email,          null: false
      t.string     :phone_number
      t.string     :address
      t.string     :company_email
      t.string     :image

      #------------------------- Devise ------------------------ #

      # Required
      t.string :provider, null: false, default: "email"
      t.string :uid, null: false, default: ""

      # Database authenticatable
      t.string :encrypted_password

      # Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # Rememberable
      t.datetime :remember_created_at

      # Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      # Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      # Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      # User Info
      t.string :nickname

      # Tokens
      t.text :tokens

      t.timestamps null: false
    end

    add_index :supervisors, :email
    add_index :supervisors, [:uid, :provider],     :unique => true
    add_index :supervisors, :reset_password_token, :unique => true
  end
end
