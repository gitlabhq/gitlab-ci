class AddTravisSupport < ActiveRecord::Migration
  def change
    add_column :projects, :type, :string, default: 'shell'
    add_column :projects, :travis_environment, :string

    add_column :builds, :type, :string, default: 'shell'
    add_column :builds, :language, :string, default: 'shell'
    add_column :builds, :attributes, :string
    add_column :builds, :matrix_attributes, :string
  end
end
