module FightsHelper
  def hide_on_vote(vote,n)
    return '' if vote == 0
    vote==n ? 'hidden' : ''
  end
  def show_on_vote(vote,n)
    return 'hidden' if vote == 0 
    vote!=n ? 'hidden' : ''    
  end
  def hide_when_vote(vote)
    vote != 0 ? 'hidden' : ''
  end
end
