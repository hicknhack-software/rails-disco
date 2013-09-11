class CreateDomainEvents < ActiveRecord::Migration
  def change
    create_table :domain_events do |t|
      t.string :event
      t.text :data
      t.datetime :created_at
    end
  end
end
