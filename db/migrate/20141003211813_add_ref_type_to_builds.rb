class AddRefTypeToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :ref_type, :string, :default => 'heads'
  end
end
