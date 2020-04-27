require "test_helper"

class Rails::Static::SiteTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rails::Static::Site::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
