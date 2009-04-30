class Notifier < ActionMailer::Base
  include ApplicationHelper

  REPLY_TO = "Mockr <do-not-reply@causes.com>"

  def new_comment(comment)
    from REPLY_TO
    reply_to REPLY_TO
    subject "#{comment.mock.title}"
    recipients comment.recipient_emails
    content_type "text/html"
    body :comment => comment
  end  
  
  def new_mock(mock, recipients = nil)
    from REPLY_TO
    recipients ||= "ui@causes.com"
    reply_to REPLY_TO
    subject "#{mock.title}"
    recipients recipients
    # content_type "text/html"
    attachment :body => File.read(mock.full_path),
               :content_type => "image/png"
    # body :mock => mock
    part :body => render_message("new_mock", :mock => mock),
         :content_type => "text/html"
  end
end
