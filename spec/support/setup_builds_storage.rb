RSpec.configure do |config|
  config.before(:each) do
    FileUtils.mkdir_p("tmp/builds_test")
    Build.any_instance.stub(:root_dir_to_trace).and_return("tmp/builds_test")
  end

  config.after(:suite) do
    Dir.chdir(Rails.root.join("tmp/builds_test")) do
      `ls | grep -v .gitkeep | xargs rm -r`
    end
  end
end
