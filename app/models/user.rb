# User object is stored in session
class User
  attr_reader :attributes

  def initialize(hash)
    @attributes = hash
  end

  def gitlab_projects(page = 1, per_page = 100)
    Project.from_gitlab(self, page, per_page, :authorized)
  end

  def method_missing(meth, *args, &block)
    if attributes.has_key?(meth.to_s)
      attributes[meth.to_s]
    else
      super
    end
  end
end
