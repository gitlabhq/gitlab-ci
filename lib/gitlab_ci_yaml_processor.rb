class GitlabCiYamlProcessor
  attr_reader :before_script, :skip_refs

  def initialize(config)
    @config = YAML.load(config).deep_symbolize_keys
    @skip_refs = @config[:skip_refs] || ""
    @before_script = @config[:before_script] || []
    @jobs = @config[:jobs] || []
    @deploy_jobs = @config[:deploy_jobs] || []
  end

  def builds
    normalized_jobs.map do |job|
      {
        name: job[:name],
        commands: "#{@before_script.join("\n")}\n#{job[:script]}",
        tag_list: job[:runner],
        branches: job[:branches],
        tags: job[:tag]
      }
    end
  end

  def deploy_builds
    normalized_deploy_jobs.map do |job|
      {
        name: job[:name],
        commands: "#{@before_script.join("\n")}\n#{job[:script]}",
        deploy: true,
        refs: job[:refs],
        tag_list: job[:runner]
      }
    end
  end

  def create_commit_for_tag?(ref)
    normalized_jobs.any?{|job| job[:tags] == true} ||
    normalized_deploy_jobs.any?{|job| job[:refs].empty? || refs_matches?(job[:refs], ref)}
  end

  def deploy_builds_for_ref(ref)
    deploy_builds.select do |build_attrs|
      refs = build_attrs.delete(:refs)
      refs.empty? || refs_matches?(refs, ref)
    end
  end

  def skip_ref?(ref_name)
    @skip_refs.split(",").each do |ref|
      return true if File.fnmatch(ref, ref_name)
    end

    false
  end

  private

  # refs - list of refs. Glob syntax is supported. Ex. ["feature*", "bug"]
  # ref - ref that should be checked
  def refs_matches?(refs, ref)
    refs.each do |ref_pattern|
      return true if File.fnmatch(ref_pattern, ref)
    end

    false
  end

  def normalized_jobs
    @jobs.map do |job|
      if job.is_a?(String)
        { script: job, runner: "", name: job[0..10], branches: true, tags: true }
      else
        {
          script: job[:script].strip,
          runner: job[:runner] || "",
          name: job[:name] || job[:script][0..10],
          branches: job[:branches].nil? ? true : job[:branches],
          tags: job[:tags].nil? ? true : job[:tags]
        }
      end
    end
  end

  def normalized_deploy_jobs
    @deploy_jobs.map do |job|
      if job.is_a?(String)
        { script: job, refs: [], name: job[0..10].strip }
      else
        {
          script: job[:script].strip,
          refs: (job[:refs] || "").split(",").map(&:strip),
          name: job[:name] || job[:script][0..10].strip,
          runner: job[:runner] || "",
        }
      end
    end
  end
end
