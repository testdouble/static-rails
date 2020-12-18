require "application_system_test_case"

class BasicsTest < ApplicationSystemTestCase
  parallelize(workers: 8)

  24.times do |i|
    define_method "test_route_that_uses_csrf_protection_#{i}" do
      visit "http://blog.localhost/docs"

      assert_text "API liked our CSRF token and sent back ID: 22"
    end
  end
end
