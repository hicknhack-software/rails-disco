class CreateUniqueCommandIds < ActiveRecord::Migration
  def change
    create_table :unique_command_ids do |t|
      t.string :command
      t.integer :last_id
    end
    add_index :unique_command_ids, :command, unique: true
  end
end
