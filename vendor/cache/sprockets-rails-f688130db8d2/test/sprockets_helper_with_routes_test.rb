require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class SprocketsHelperWithRoutesTest < ActiveSupport::TestCase
  include Sprockets::Rails::Helpers::RailsHelper

  attr_accessor :controller, :params

  # Let's bring in some named routes to test namespace conflicts with potential *_paths.
  # We have to do this after we bring in the Sprockets RailsHelper so if there are conflicts,
  # they'll fail in the way we expect in a real live Rails app.
  routes = ActionDispatch::Routing::RouteSet.new
  routes.draw do
    resources :assets
  end
  include routes.url_helpers

  def setup
    @controller = BasicController.new

    @assets = Sprockets::Environment.new
    @assets.append_path(FIXTURES.join("app/javascripts"))
    @assets.append_path(FIXTURES.join("app/stylesheets"))
    @assets.append_path(FIXTURES.join("app/images"))

    application = Struct.new(:config, :assets).new(config, @assets)
    ::Rails.stubs(:application).returns(application)
    @config = config
    @config.perform_caching = true
    @config.assets.digest = true
    @config.assets.compile = true
    @params = {}
  end

  def config
    @controller ? @controller.config : @config
  end

  test "namespace conflicts on a named route called asset_path" do
    # Testing this for sanity - asset_path is now a named route!
    assert_equal asset_path('test_asset'), '/assets/test_asset'

    assert_match %r{/assets/logo-[0-9a-f]+.png},
      path_to_asset("logo.png")
    assert_match %r{/assets/logo-[0-9a-f]+.png},
      path_to_asset("logo.png", :digest => true)
    assert_match %r{/assets/logo.png},
      path_to_asset("logo.png", :digest => false)
  end

  test "javascript_include_tag with a named_route named asset_path" do
    assert_match %r{<script src="/assets/application-[0-9a-f]+.js"></script>},
      javascript_include_tag(:application)
  end

  test "stylesheet_link_tag with a named_route named asset_path" do
    assert_match %r{<link href="/assets/application-[0-9a-f]+.css" media="screen" rel="stylesheet" />},
      stylesheet_link_tag(:application)
  end

end
