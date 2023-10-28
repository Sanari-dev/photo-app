class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :name
      t.string :picture
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
