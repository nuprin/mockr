# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def nl2br(text)
    text.gsub(/\r\n?/, "\n").gsub(/\n/, '<br />')
  end
end
