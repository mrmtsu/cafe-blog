class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.string :name
      t.text :description
      t.integer :place
      t.string :address
      t.float :latitude
      t.float :longitude
      t.text :reference
      t.integer :popularity
      t.text :cafe_memo
      t.references :user, foreign_key: true
      t.timestamps
    end
    add_index :articles, [:user_id, :created_at]
  end
end
