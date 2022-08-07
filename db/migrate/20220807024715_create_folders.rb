class CreateFolders < ActiveRecord::Migration[6.1]
  def change
    create_table :folders do |t|
      t.string :name
      t.integer :organization_id
      t.integer :video_id

      t.timestamps
    end
  end
end
