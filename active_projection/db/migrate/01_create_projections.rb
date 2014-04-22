class CreateProjections < ActiveRecord::Migration
  def change
    create_table :projections do |t|
      t.string :class_name
      t.integer :last_id, default: 0
      t.boolean :solid, default: true
    end
    add_index :projections, :class_name
  end
end
