class Project
  attr_accessor :status, :name

  def initialize(name, status)
    @name, @status = name, status
  end
end
