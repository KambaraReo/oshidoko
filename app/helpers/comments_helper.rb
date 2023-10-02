module CommentsHelper
  def get_percent(number)
    if number.present?
      calc_percent = number / 5.to_f * 100
      percent = calc_percent.round
      percent.to_s
    else
      0
    end
  end
end
