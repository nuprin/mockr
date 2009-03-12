# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def format_text(text)
    text = nl2br(text)
    auto_link(text, :all, :target => "_blank")
  end
  
  def nl2br(text)
    text.gsub(/\r\n?/, "\n").gsub(/\n/, '<br />')
  end
end
