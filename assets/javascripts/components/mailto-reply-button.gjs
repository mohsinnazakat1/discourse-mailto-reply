// assets/javascripts/components/mailto-reply-button.gjs
import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";

function stripHtml(html) {
  const div = document.createElement("div");
  div.innerHTML = html || "";
  return (div.textContent || div.innerText || "").trim();
}

// RFC 6068: encode and use %0D%0A for line breaks
function crlf(lines) {
  return lines.join("\r\n");
}

export default class MailtoReplyButton extends Component {
  @service siteSettings;

  static hidden() {
    return false;
  }

  get label() {
    return "mailto_reply.label";
  }

  get title() {
    return "mailto_reply.title";
  }

  @action
  openMailto() {
    const post = this.args.post; // provided by post-menu API
    const to = this.siteSettings.mailto_reply_to_address || "";
    if (!to) return;

    // Subject with "Re:" prefix if missing
    let subject = post.topic?.title || post.topic_title || "";
    if (!/^re:/i.test(subject)) subject = `Re: ${subject}`;

    // Basic quoted body (optional)
    let body = "";
    if (this.siteSettings.mailto_reply_include_body) {
      const author = post.username || "";
      const cooked = post.cooked || "";
      const quoted = stripHtml(cooked)
        .split(/\r?\n/)
        .map((l) => `> ${l}`)
        .join("\r\n");
      const link = window.location.origin + (post.url || "");
      body = crlf([
        `On ${new Date(post.created_at).toISOString()} @${author} wrote:`,
        quoted,
        "",
        link,
      ]);
    }

    // Best-effort threading headers — some clients ignore them
    // RFC 6068 allows arbitrary header fields; clients may ignore. 
    const headers = [];
    headers.push(`subject=${encodeURIComponent(subject)}`);
    if (this.siteSettings.mailto_reply_include_body && body) {
      headers.push(`body=${encodeURIComponent(body)}`);
    }
    if (this.siteSettings.mailto_reply_include_headers) {
      const host = window.location.hostname;
      // Synthetic ID similar to patterns seen in Discourse emails to keep topics together
      const syntheticId = `<topic/${post.topic_id}/${post.id}@${host}>`;
      headers.push(`In-Reply-To=${encodeURIComponent(syntheticId)}`);
      headers.push(`References=${encodeURIComponent(syntheticId)}`);
      // Thread-Topic maps to subject; Thread-Index is not generated (Exchange-specific)
      headers.push(`Thread-Topic=${encodeURIComponent(subject)}`);
    }

    const mailto = `mailto:${encodeURIComponent(to)}?${headers.join("&")}`;
    window.location.href = mailto;
  }

  <template>
    <DButton
      class="post-action-menu__mailto-reply"
      @action={{this.openMailto}}
      @icon="envelope"
      @label={{this.label}}
      @title={{this.title}}
    />
  </template>
}
