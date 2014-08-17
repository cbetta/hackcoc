class CreateSupporters < ActiveRecord::Migration
  def change
    create_table :supporters do |t|
      t.string :name
      t.string :title
      t.string :hack
      t.boolean :is_supporter
      t.boolean :is_custom
      t.string :email
      t.string :phone
      t.string :url
      t.string :slug

      t.timestamps
    end
  end
end
