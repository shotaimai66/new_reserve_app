class CreateDeliveryMassages < ActiveRecord::Migration[5.2]
  def change
    create_table :delivery_massages do |t|
      t.string :title
      t.text :message, null: false
      t.datetime :delivery_date, null: false, comment:"配信日時"
      t.boolean :is_draft, default: false, comment: "下書きかどうかのフラグ"

      t.references :calendar, foreign_key: true

      t.timestamps
    end
  end
end
