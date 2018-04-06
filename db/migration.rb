class RightOnMigration < ActiveRecord::Migration
  def self.change
    create_table :rights do |t|
      t.string :name, :controller, :action, limit: 150
      t.timestamps
    end

    change_table :rights do |t|
      t.index :action
      t.index :name
      t.index %i[controller action]
    end

    create_table :rights_roles, id: false do |t|
      t.integer %i[right_id role_id]
    end

    change_table :rights_roles do |t|
      t.index %i[right_id role_id]
      t.index %i[role_id right_id]
    end

    create_table :roles do |t|
      t.string  :title
      t.text    :description
      t.integer :right_id
      t.timestamps
    end

    change_table :roles do |t|
      t.index :right_id
    end
  end
end
