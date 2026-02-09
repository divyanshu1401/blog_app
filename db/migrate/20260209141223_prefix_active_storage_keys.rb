class PrefixActiveStorageKeys < ActiveRecord::Migration[7.2]
  def up
    # We use find_each to avoid loading thousands of objects into memory at once
    ActiveStorage::Blob.find_each(batch_size: 1000) do |blob|
      unless blob.key.start_with?("uploads/")
        # update_column is faster and skips 'updated_at' changes/callbacks
        blob.update_column(:key, "uploads/#{blob.key}")
      end
    end
  end

  def down
    ActiveStorage::Blob.find_each(batch_size: 1000) do |blob|
      if blob.key.start_with?("uploads/")
        new_key = blob.key.delete_prefix("uploads/")
        blob.update_column(:key, new_key)
      end
    end
  end
end
