class Entry < ActiveRecord::Base

  # FILTER = %w(the be to of and a in that have I it for not on with he as you do at this but his by from they we say her she or an will my one all would there their what so up out if about who get which go me when make can like time no just him know take person into year your good some could them see other than then now look only come its over think also back after use two how our work first well way even new want because any these give day most us)

  def self.decompose_titles(start, finish)
    string = where('published BETWEEN ? AND ?', start, finish).limit(100).pluck(:title, :summary).flatten.join(' ').downcase
    string = ActionView::Base.full_sanitizer.sanitize(string)
    string = HTMLEntities.new.decode(string)
    return [] if string.empty?
    result = EngTagger.new.get_words(string).to_a
    result = result.reject {|item| item.last < 10}
    result.sort {|a,b| b.last <=> a.last}
  end

end
