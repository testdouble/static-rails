$stdout.sync = true

def enhance_assets_precompile
  Rake::Task["assets:precompile"].enhance([]) do
    Rake::Task["static:compile"].invoke
  end
end

namespace :static do
  desc "Compile static sites configured with static-rails"
  task compile: :environment do
    StaticRails.compile
  end
end

if Rake::Task.task_defined?("assets:precompile")
  enhance_assets_precompile
else
  Rake::Task.define_task("assets:precompile" => "static:compile")
end
