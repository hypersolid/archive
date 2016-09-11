include ActionView::Helpers::NumberHelper
include ActionView::Helpers::TextHelper
  
module CommonHelpers
  def score(amount)
    number_with_delimiter amount
  end

  # take a screenshot
  def screenshot
    @number = @number ? @number += 1 : 1
    `/usr/bin/import -window root ./screen#{@number}.png`
  end
end