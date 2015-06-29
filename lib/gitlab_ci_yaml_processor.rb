class GitlabCiYamlProcessor
  class ValidationError < StandardError;end

  attr_reader :before_script

  def initialize(config)
    @config = YAML.load(config)

    unless @config.is_a? Hash
      raise ValidationError, "YAML should be a hash"
    end

    @config = @config.deep_symbolize_keys

    initial_parsing

    validate!
  end

  def deploy_builds_for_ref(ref, tag = false)
    deploy_builds.select{|build| process?(build[:only], build[:except], ref, tag)}
  end

  def builds_for_ref(ref, tag = false)
    builds.select{|build| process?(build[:only], build[:except], ref, tag)}
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

  def initial_parsing
    @before_script = @config[:before_script] || []
    @config.delete(:before_script)

    unless @config.is_a?(Hash) && !@config.values.any?{|job| !job.is_a?(Hash)}
      raise ValidationError, "Please define at least one job"
    end

    @jobs = @config.select{|key, value| value[:type] != "deploy"}
    @deploy_jobs = @config.select{|key, value| value[:type] == "deploy"}
  end

  def process?(only_params, except_params, ref, tag)
    return true if only_params.nil? && except_params.nil?

    if only_params
      return true if tag && only_params.include?("tags")
      return true if !tag && only_params.include?("branches")
      
      only_params.find do |pattern|
        match_ref?(pattern, ref)
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
    unless @before_script.is_a?(Array)
      raise ValidationError, "before_script should be an array"
    end

    @jobs.each do |name, job|
      job.keys.each do |key|
        unless [:tags, :script, :only, :except, :type].include? key
          raise ValidationError, "#{name} job: unknow parameter #{key}"
        end
      end

      if job[:tags] && !job[:tags].is_a?(Array)
        raise ValidationError, "#{name} job: tags parameter should be an array"
      end

      if job[:only] && !job[:only].is_a?(Array)
        raise ValidationError, "#{name} job: only parameter should be an array"
      end

      if job[:except] && !job[:except].is_a?(Array)
        raise ValidationError, "#{name} job: except parameter should be an array"
      end
    end

    @deploy_jobs.each do |name, job|
      job.keys.each do |key|
        unless [:tags, :script, :only, :except, :type].include? key
          raise ValidationError, "#{name} job: unknow parameter #{key}"
        end
      end
      
      if job[:tags] && !job[:tags].is_a?(Array)
        raise ValidationError, "#{name} deploy job: tags parameter should be an array"
      end

      if job[:only] && !job[:only].is_a?(Array)
        raise ValidationError, "#{name} deploy job: only parameter should be an array"
      end

      if job[:except] && !job[:except].is_a?(Array)
        raise ValidationError, "#{name} deploy job: except parameter should be an array"
      end
    end

    true
  end
end
