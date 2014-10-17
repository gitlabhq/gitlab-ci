class MigrateAttributesToBuildParameters < ActiveRecord::Migration
  def change
    reversible do |migration|
      migration.up do
        Build.where(build_method: :travis).each do |build|
          build_attributes = build.build_attributes
          build_config = build_attributes[:config] || build_attributes['config']
          next unless build_config
          build_os = build_config[:os] || build_config['os'] || 'linux'
          build_language = build_config[:language] || build_config['language'] || 'ruby'
          build_attributes[:config] ||= build_config
          build_attributes[:matrix_config] ||= build.matrix_attributes
          build.update_attributes!(
              build_os: build_os,
              build_image: "ayufan/travis-#{build_os}-worker:#{build_language}",
              build_attributes: build_attributes
          )
        end
      end
      migration.down
    end
  end
end
