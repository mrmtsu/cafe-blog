class RenamePlaceColumnToArticles < ActiveRecord::Migration[5.2]
  def change
    rename_column :articles, :place, :place_id
  end
end
