module StaticRails
  def self.compile
    CompilesSites.new.call(StaticRails.config)
  end

  class CompilesSites
    def call(config)
      config.sites.each do |site|
        Dir.chdir(config.app.root.join(site.source_dir)) do
          Bundler.with_unbundled_env do
            puts "=> Compiling static site \"#{site.name}\" to #{site.compile_dir}"
            result = system site.compile_command
            unless result == true
              raise Error.new("Compilation of static site \"#{site.name}\" failed (in directory \"#{site.source_dir}\" with command: `#{site.compile_command}`)")
            end
          end
        end
      end
    end
  end
end
