# User object is stored in session
class User
  attr_reader :attributes

  def initialize(hash)
    @attributes = hash
  end

  def gitlab_projects(page = 1, per_page = 100)
    Rails.cache.fetch(cache_key(page, per_page)) do
      Project.from_gitlab(self, page, per_page, :authorized)
    end
  end

  def method_missing(meth, *args, &block)
    if attributes.has_key?(meth.to_s)
      attributes[meth.to_s]
    else
      super
    end
  end

  def cache_key(*args)
    "#{self.id}:#{args.join(":")}:#{sync_at.to_s}"
  end

  def sync_at
    @sync_at ||= Time.now
  end

  def reset_cache
    @sync_at = Time.now
  end

  def can_access_project?(project_gitlab_id)
    opts = {
      private_token: self.private_token,
    }

    Rails.cache.fetch(cache_key(project_gitlab_id, sync_at)) do
      !!Network.new.project(self.url, opts, project_gitlab_id)
    end
  end
end
