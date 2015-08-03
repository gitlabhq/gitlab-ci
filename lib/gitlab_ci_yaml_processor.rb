class GitlabCiYamlProcessor
  class ValidationError < StandardError;end

  DEFAULT_TYPES = %w(build test deploy)
  DEFAULT_TYPE = 'test'
  ALLOWED_JOB_KEYS = [:tags, :script, :only, :except, :type, :image, :services, :allow_failure, :type]

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

  def builds_for_type_and_ref(type, ref, tag = false)
    builds.select{|build| build[:type] == type && process?(build[:only], build[:except], ref, tag)}
  end

  def builds
    @jobs.map do |name, job|
      build_job(name, job)
    end
  end

  def types
    @types || DEFAULT_TYPES
  end

  private

  def initial_parsing
    @before_script = @config[:before_script] || []
    @image = @config[:image]
    @services = @config[:services]
    @types = @config[:types]
    @config.except!(:before_script, :image, :services, :types)

    @config.each do |name, param|
      raise ValidationError, "Unknown parameter: #{name}" unless param.is_a?(Hash)
    end

    unless @config.values.any?{|job| job.is_a?(Hash)}
      raise ValidationError, "Please define at least one job"
    end

    @jobs = {}
    @config.each do |key, job|
      @jobs[key] = { type: DEFAULT_TYPE }.merge(job)
    end
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
      type: job[:type],
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
    unless validate_array_of_strings(@before_script)
      raise ValidationError, "before_script should be an array of strings"
    end

    unless @image.nil? || @image.is_a?(String)
      raise ValidationError, "image should be a string"
    end

    unless @services.nil? || validate_array_of_strings(@services)
      raise ValidationError, "services should be an array of strings"
    end

    unless @types.nil? || validate_array_of_strings(@types)
      raise ValidationError, "types should be an array of strings"
    end

    @jobs.each do |name, job|
      validate_job!("#{name} job", job)
    end

    true
  end

  def validate_job!(name, job)
    job.keys.each do |key|
      unless ALLOWED_JOB_KEYS.include? key
        raise ValidationError, "#{name}: unknown parameter #{key}"
      end
    end

    unless job[:type].is_a?(String)
      raise ValidationError, "#{name}: type should be a string"
    end

    unless job[:type].in?(types)
      raise ValidationError, "#{name}: type parameter should be #{types.join(", ")}"
    end

    if job[:image] && !job[:image].is_a?(String)
      raise ValidationError, "#{name}: image should be a string"
    end

    if job[:services] && !validate_array_of_strings(job[:services])
      raise ValidationError, "#{name}: services should be an array of strings"
    end

    if job[:tags] && !validate_array_of_strings(job[:tags])
      raise ValidationError, "#{name}: tags parameter should be an array of strings"
    end

    if job[:only] && !validate_array_of_strings(job[:only])
      raise ValidationError, "#{name}: only parameter should be an array of strings"
    end

    if job[:except] && !validate_array_of_strings(job[:except])
      raise ValidationError, "#{name}: except parameter should be an array of strings"
    end

    if job[:allow_failure] && !job[:allow_failure].in?([true, false])
      raise ValidationError, "#{name}: allow_failure parameter should be an boolean"
    end
  end

  private

  def validate_array_of_strings(values)
    values.is_a?(Array) && values.all? {|tag| tag.is_a?(String)}
  end
end
