class AddBuildParameters < ActiveRecord::Migration
  def change
    add_column :builds, :build_os, :string, default: ''
    add_column :builds, :build_image, :string, default: ''
    add_column :projects, :build_os, :string, default: 'linux'
    add_column :projects, :build_image, :string, default: ''
  end
end
