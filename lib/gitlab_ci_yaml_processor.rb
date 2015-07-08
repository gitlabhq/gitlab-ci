class GitlabCiYamlProcessor
  class ValidationError < StandardError;end

  attr_reader :before_script, :image, :services

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
      build_job(name, job)
    end
  end

  def deploy_builds
    @deploy_jobs.map do |name, job|
      build_job(name, job)
    end
  end

  private

  def initial_parsing
    @before_script = @config[:before_script] || []
    @image = @config[:image]
    @services = @config[:services]
    @config.except!(:before_script, :image, :services)

    @config.each do |name, param|
      raise ValidationError, "Unknown parameter: #{name}" unless param.is_a?(Hash)
    end

    unless @config.values.any?{|job| job.is_a?(Hash)}
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

  def build_job(name, job)
    {
      script: "#{@before_script.join("\n")}\n#{normalize_script(job[:script])}",
      tags: job[:tags] || [],
      name: name,
      only: job[:only],
      except: job[:except],
      allow_failure: job[:allow_failure] || false,
      options: {
        image: job[:image] || @image,
        services: job[:services] || @services
      }.compact
    }
  end

  def match_ref?(pattern, ref)
    if pattern.first == "/" && pattern.last == "/"
      Regexp.new(pattern[1...-1]) =~ ref
    else
      pattern == ref
    end
  end

  def normalize_script(script)
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

    unless @image.nil? || @image.is_a?(String)
      raise ValidationError, "image should be a string"
    end

    unless @services.nil? || @services.is_a?(Array) && @services.all? {|service| service.is_a?(String)}
      raise ValidationError, "services should be an array of strings"
    end

    @jobs.each do |name, job|
      validate_job!("#{name} job", job)
    end

    @deploy_jobs.each do |name, job|
      validate_job!("#{name} deploy job", job)
    end

    true
  end

  def validate_job!(name, job)
    job.keys.each do |key|
      unless [:tags, :script, :only, :except, :type, :image, :services, :allow_failure].include? key
        raise ValidationError, "#{name}: unknown parameter #{key}"
      end
    end

    if job[:image] && !job[:image].is_a?(String)
      raise ValidationError, "#{name}: image should be a string"
    end

    if job[:services]
      unless job[:services].is_a?(Array) && job[:services].all? {|service| service.is_a?(String)}
        raise ValidationError, "#{name}: services should be an array of strings"
      end
    end

    if job[:tags] && !job[:tags].is_a?(Array)
      raise ValidationError, "#{name}: tags parameter should be an array"
    end

    if job[:only] && !job[:only].is_a?(Array)
      raise ValidationError, "#{name}: only parameter should be an array"
    end

    if job[:except] && !job[:except].is_a?(Array)
      raise ValidationError, "#{name}: except parameter should be an array"
    end

    if job[:allow_failure] && !job[:allow_failure].in?([true, false])
      raise ValidationError, "#{name}: allow_failure parameter should be an boolean"
    end
  end
end
