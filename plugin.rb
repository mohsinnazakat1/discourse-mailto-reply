# name: discourse-mailto-reply
# about: Adds mailto reply functionality to posts that opens email client with pre-composed drafts
# version: 1.0.0
# authors: YourName
# url: https://github.com/yourusername/discourse-mailto-reply

enabled_site_setting :mailto_reply_enabled

PLUGIN_NAME = "discourse-mailto-reply".freeze

after_initialize do
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

  # Register plugin
  register_asset "stylesheets/mailto-reply.scss"
end
