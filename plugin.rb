# name: discourse-mailto-reply
# about: Adds mailto reply functionality to posts that opens email client with pre-composed drafts
# version: 1.0.0
# authors: YourName
# url: https://github.com/yourusername/discourse-mailto-reply

PLUGIN_NAME = "discourse-mailto-reply".freeze

# Register settings directly in plugin.rb
register_asset "stylesheets/mailto-reply.scss"

after_initialize do
  Sentry.init do |config|
    config.dsn = 'https://e5a1464540463ca9c200fe70d33961f2@o4509722905673728.ingest.de.sentry.io/4510000222896208'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Add data like request headers and IP for users,
    # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
    config.send_default_pii = true
  end
  # Add site settings
  SiteSetting.add_setting(:mailto_reply_enabled, false, type: :bool, client: true)
  SiteSetting.add_setting(:mailto_reply_address, "", type: :string, client: true)
  SiteSetting.add_setting(:mailto_reply_include_quoted_text, true, type: :bool, client: true)
  SiteSetting.add_setting(:mailto_reply_include_headers, true, type: :bool, client: true)

  # Only proceed if enabled
  if SiteSetting.mailto_reply_enabled
    
    # Load the lib file first
    require_dependency File.expand_path('../lib/mailto_link_generator.rb', __FILE__)

    # Add routes
    Discourse::Application.routes.append do
      get '/mailto-reply-link' => 'mailto_reply#generate_link'
    end

    # Load controller
    require_dependency File.expand_path('../app/controllers/mailto_reply_controller.rb', __FILE__)
    
    # Add serializer fields
    add_to_serializer(:post, :can_mailto_reply) do
      SiteSetting.mailto_reply_enabled && scope.authenticated?
    end
  end
end
