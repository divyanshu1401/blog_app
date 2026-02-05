class AddUniqueIndexToLike < ActiveRecord::Migration[7.2]
  def change
    add_index :likes, [:user_id, :post_id], unique: true
  end
end
