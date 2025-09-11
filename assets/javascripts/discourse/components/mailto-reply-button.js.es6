import Component from "@ember/component";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default Component.extend({
  tagName: "span",
  classNames: ["mailto-reply-wrapper"],
  
  @action
  openMailtoReply() {
    const postId = this.get("post.id");
    
    ajax("/mailto-reply-link", {
      type: "GET",
      data: { post_id: postId }
    })
    .then((result) => {
      if (result.mailto_url) {
        this.openEmailClient(result.mailto_url);
      }
    })
    .catch(popupAjaxError);
  },

  openEmailClient(mailtoUrl) {
    // Try to open mailto link
    const link = document.createElement("a");
    link.href = mailtoUrl;
    link.click();
    
    // For better UX, show a brief notification
    this.showNotification();
  },

  showNotification() {
    // Optional: show user feedback that email client should open
    if (window.bootbox) {
      bootbox.alert({
        message: "Your email client should open with a pre-composed reply.",
        size: "small",
        backdrop: true
      });
    }
  }
});
