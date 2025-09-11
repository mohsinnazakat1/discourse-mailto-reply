# frozen_string_literal: true

class MailtoReplyController < ApplicationController
  requires_login

  def generate_link
    post = Post.find(params[:post_id])
    topic = post.topic
    
    guardian.ensure_can_see!(post)
    
    mailto_url = MailtoLinkGenerator.generate(post, topic, current_user)
    
    render json: { mailto_url: mailto_url }
  rescue Discourse::InvalidAccess => e
    render json: { error: "Access denied" }, status: 403
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Post not found" }, status: 404
  rescue => e
    render json: { error: e.message }, status: 400
  end
end
