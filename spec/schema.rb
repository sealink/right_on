ActiveRecord::Schema.define(:version => 1) do
  create_table :rights do |t|
    t.string   :name, :controller, :action, :limit => 150
    t.timestamps
  end

  change_table :rights do |t|
    t.index :action
    t.index [:controller, :action]
    t.index :name
  end

  create_table :rights_roles, :id => false do |t|
    t.integer :right_id, :role_id
  end

  change_table :rights_roles do |t|
    t.index [:right_id, :role_id]
    t.index [:role_id, :right_id]
  end

  create_table :roles do |t|
    t.string  :title
    t.text    :description
    t.integer :right_id
    t.timestamps
  end

  add_index :roles, :right_id

  create_table :models do |t|
    t.string  :name
    t.integer :right_id
  end
end

