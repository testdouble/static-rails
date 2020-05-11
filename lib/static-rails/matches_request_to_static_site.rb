module StaticRails
  class MatchesRequestToStaticSite
    def call(request)
      StaticRails.config.sites.find { |site|
        subdomain_match?(site, request) && path_match?(site, request) && !skip_path?(site, request)
      }
    end

    private

    def subdomain_match?(site, request)
      return true if site.url_subdomain.nil?

      expected = site.url_subdomain.split(".")
      actual = request.host.split(".")

      expected.enum_for.with_index.all? { |sub, i| actual[i] == sub }
    end

    def path_match?(site, request)
      request.path_info.start_with?(site.url_root_path)
    end

    def skip_path?(site, request)
      site.url_skip_paths_starting_with.any? { |path_start|
        request.path_info.start_with?(path_start)
      }
    end
  end
end
