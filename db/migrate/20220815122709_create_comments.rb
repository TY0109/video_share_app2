class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :comment, null: false
      t.references :user, null: false, foreign_key: true
      t.references :viewer, null: false, foreign_key: true
      t.references :loginless_viewer, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.references :video, null: false, foreign_key: true

      t.timestamps
    end
  end
end
