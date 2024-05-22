class RemoveDataUrlFromVideos < ActiveRecord::Migration[6.1]
  def up
    remove_column :videos, :data_url
  end

  def down
    add_column :videos, :data_url, :string
  end
end
