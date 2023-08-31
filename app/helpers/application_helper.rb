module ApplicationHelper
  BASE_TITLE = "OSHIDOKO - 日向坂46の聖地マップ".freeze

  def full_title(page_title)
    page_title.blank? ? BASE_TITLE : "#{page_title} | #{BASE_TITLE}"
  end
end
