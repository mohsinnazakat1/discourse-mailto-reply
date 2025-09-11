# frozen_string_literal: true

class MailtoLinkGenerator
  def self.generate(post, topic, user)
    new(post, topic, user).generate
  end

  def initialize(post, topic, user)
    @post = post
    @topic = topic
    @user = user
  end

  def generate
    params = {
      "to" => mailing_list_address,
      "subject" => reply_subject,
      "body" => reply_body
    }

    # Add threading headers for better email client support
    params.merge!(threading_headers) if include_threading_headers?

    build_mailto_url(params)
  end

  private

  attr_reader :post, :topic, :user

  def mailing_list_address
    SiteSetting.mailto_reply_address.presence || "noreply@#{Discourse.current_hostname}"
  end

  def reply_subject
    subject = topic.title
    subject.start_with?("Re:") ? subject : "Re: #{subject}"
  end

  def reply_body
    quoted_content = create_quoted_content
    signature = create_signature
    
    "#{signature}#{quoted_content}"
  end

  def create_quoted_content
    return "" unless SiteSetting.mailto_reply_include_quoted_text

    original_text = post.raw
    author = post.user.name.presence || post.user.username
    date = post.created_at.strftime("%B %d, %Y at %I:%M %p")
    
    quoted_lines = original_text.lines.map { |line| "> #{line.chomp}" }.join("\n")
    
    "\n\nOn #{date}, #{author} wrote:\n#{quoted_lines}"
  end

  def create_signature
    return "" unless user&.name.present?
    
    "\n\n--\n#{user.name}\n"
  end

  def threading_headers
    {
      "In-Reply-To" => message_id,
      "References" => message_id,
      "Thread-Topic" => topic.title
    }
  end

  def message_id
    "<discourse-post-#{post.id}@#{Discourse.current_hostname}>"
  end

  def include_threading_headers?
    SiteSetting.mailto_reply_include_headers
  end

  def build_mailto_url(params)
    query_parts = params.compact.map do |key, value|
      "#{key}=#{CGI.escape(value.to_s)}"
    end
    
    "mailto:?#{query_parts.join('&')}"
  end
end
