class CreateCommitsFromBuilds < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.integer :project_id
      t.string  :ref,        nil: false
      t.string  :sha,        nil: false
      t.string  :before_sha, nil: false
      t.text    :push_data,  nil: false

      t.timestamps
    end

    reversible do |migration|
      migration.up { init_commits }
      migration.down {}
    end

    add_column :builds, :commit_id, :integer

    reversible do |migration|
      migration.up { associate_builds_with_commit }
      migration.down { dissociate_builds_with_commit }
    end

    # Remove commit data from builds
    #  -- don't use change_table, its not very reversible
    remove_column :builds, :project_id, :integer
    remove_column :builds, :ref,        :string
    remove_column :builds, :sha,        :string
    remove_column :builds, :before_sha, :string
    remove_column :builds, :push_data,  :text
  end

  private

  def init_commits
    Commit.reset_column_information

    # Create one Commit for each unique sha value
    shas = Build.pluck(:sha).uniq
    shas.each do |sha|
      # Get latest build for a particular commit
      build = Build.where(sha: sha).order('created_at desc').first
      attributes = {
        project_id: build.project_id,
        ref: build.ref,
        sha: build.sha,
        before_sha: build.before_sha,
        push_data: build.push_data,
        # Original commit status matches the latest build status
        status: build.status
      }

      Commit.create!(attributes)
    end
  end

  def associate_builds_with_commit
    Build.reset_column_information
    Build.find_each do |build|
      build.commit_id = Commit.find_by_sha(build.sha).id
      build.save!
    end
  end

  def dissociate_builds_with_commit
    Build.reset_column_information
    Build.find_each do |build|
      # Don't assume an assocation exists
      commit = Commit.find(build.commit_id)

      build.project_id = commit.project_id
      build.ref = commit.ref
      build.sha = commit.sha
      build.before_sha = commit.before_sha
      build.push_data = commit.push_data
      build.save!
    end
  end
end
