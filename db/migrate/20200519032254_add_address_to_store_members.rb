class AddAddressToStoreMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :store_members, :address, :string
  end
end
