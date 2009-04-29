class Notifier < ActionMailer::Base
  REPLY_TO = "Mockr <do-not-reply@causes.com>"

  def deliver_new_comment(comment)
    reply_to REPLY_TO
    subject "(Mockr) #{comment.mock.title}"
    recipients comment.subscriber_emails
    content_type "text/html"
    body :comment => comment
  end  
end
