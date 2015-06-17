class GitlabCiYamlProcessor
  attr_reader :before_script, :skip_refs, :errors

  def initialize(config)
    @errors = []

    @config = YAML.load(config).deep_symbolize_keys
    @before_script = @config[:before_script] || []

    @config.delete(:before_script)

    @jobs = @config.select{|key, value| value[:type] != "deploy"}

    @deploy_jobs = @config.select{|key, value| value[:type] == "deploy"}

  rescue Exception => e
    @errors << "Yaml file is invalid"
  end

  def valid?
    validate!
    !@errors.any?
  end

  def deploy_builds_for_ref(ref, tag = false)
    deploy_builds.select{|build| process?(build[:only], build[:except], ref, tag)}
  end

  def builds_for_ref(ref, tag = false)
    builds.select{|build| process?(build[:only], build[:except], ref, tag)}
  end

  def any_jobs?(ref, tag = false)
    builds_for_ref(ref, tag).any? || deploy_builds_for_ref(ref, tag).any?
  end

  def builds
    @jobs.map do |name, job|
      {
        script: "#{@before_script.join("\n")}\n#{normilize_script(job[:script])}",
        tags: job[:tags] || [],
        name: name,
        only: job[:only],
        except: job[:except]
      }
    end
  end

  def deploy_builds
    @deploy_jobs.map do |name, job|
      {
        script: "#{@before_script.join("\n")}\n#{normilize_script(job[:script])}",
        tags: job[:tags] || [],
        name: name,
        only: job[:only],
        except: job[:except]
      }
    end
  end

  private

  def process?(only_params, except_params, ref, tag)
    return true if only_params.nil? && except_params.nil?

    if only_params
      return true if tag && only_params.include?("tags")
      return true if !tag && only_params.include?("branches")
      
      only_params.each do |pattern|
        return match_ref?(pattern, ref)
      end
    else
      return false if tag && except_params.include?("tags")
      return false if !tag && except_params.include?("branches")

      except_params.each do |pattern|
        return false if match_ref?(pattern, ref)
      end
    end
  end

  def match_ref?(pattern, ref)
    if pattern.first == "/" && pattern.last == "/"
      Regexp.new(pattern[1...-1]) =~ ref
    else
      pattern == ref
    end
  end

  def normilize_script(script)
    if script.is_a? Array
      script.join("\n")
    else
      script
    end
  end

  def validate!
    unless @config.is_a? Hash
      @errors << "should be a hash"
      return false
    end

    @jobs.each do |name, job|
      if job[:tags] && !job[:tags].is_a?(Array)
        @errors << "#{name} job: tags parameter should be an array"
      end

      if job[:only] && !job[:only].is_a?(Array)
        @errors << "#{name} job: only parameter should be an array"
      end

      if job[:except] && !job[:except].is_a?(Array)
        @errors << "#{name} job: except parameter should be an array"
      end
    end

    @deploy_jobs.each do |name, job|
      if job[:tags] && !job[:tags].is_a?(Array)
        @errors << "#{name} deploy job: tags parameter should be an array"
      end

      if job[:only] && !job[:only].is_a?(Array)
        @errors << "#{name} deploy job: only parameter should be an array"
      end

      if job[:except] && !job[:except].is_a?(Array)
        @errors << "#{name} deploy job: except parameter should be an array"
      end
    end

    true
  rescue
    @errors << "Undefined error"
  end
end
