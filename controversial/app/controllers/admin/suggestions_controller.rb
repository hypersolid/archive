class Admin::SuggestionsController < AdminController
 def index
   @items=Suggestion.recent
 end
end
