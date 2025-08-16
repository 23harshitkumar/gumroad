# frozen_string_literal: true

class CreateChapterFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :chapter_files do |t|
      t.references :product_file, null: true, foreign_key: true
      t.string :url, null: false
      t.string :language, default: 'English'
      t.string :file_name
      t.string :extension
      t.integer :file_size
      t.integer :size
      t.datetime :deleted_at
      t.string :external_id

      t.timestamps
    end

    add_index :chapter_files, :product_file_id
    add_index :chapter_files, :external_id
    add_index :chapter_files, :deleted_at
  end
end
