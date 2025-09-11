# name: discourse-mailto-reply
# about: Adds mailto reply functionality to posts that opens email client with pre-composed drafts
# version: 1.0.0
# authors: YourName
# url: https://github.com/yourusername/discourse-mailto-reply
gem "sentry-ruby", "5.11.0"
gem "sentry-rails", "5.11.0"

require 'sentry-ruby'
require 'sentry-rails'

enabled_site_setting :mailto_reply_enabled

PLUGIN_NAME = "discourse-mailto-reply".freeze

after_initialize do
  # Add routes
  Sentry.init do |config|
    config.dsn = 'https://e8421ac2f8734f24b68c5bb3e9aa4ace@o4509722905673728.ingest.de.sentry.io/4509722907770960'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Add data like request headers and IP for users,
    # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
    config.send_default_pii = true
  end
  Discourse::Application.routes.append do
    get '/mailto-reply-link' => 'mailto_reply#generate_link'
  end

  # Load controller
  require_dependency File.expand_path('../app/controllers/mailto_reply_controller.rb', __FILE__)
  
  # Add serializer fields
  add_to_serializer(:post, :can_mailto_reply) do
    SiteSetting.mailto_reply_enabled && scope.authenticated?
  end

  # Register plugin
  register_asset "stylesheets/mailto-reply.scss"
end
