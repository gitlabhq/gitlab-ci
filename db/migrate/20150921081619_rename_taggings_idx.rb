class RenameTaggingsIdx < ActiveRecord::Migration
  def up
    remove_index :ci_taggings, name: 'taggings_idx'
    add_index :ci_taggings,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: 'ci_taggings_idx'
  end
end
