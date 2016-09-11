class SuggestionsController < ApplicationController
 def create
   unless params[:suggestion][:text].blank?
     Suggestion.create(:text => params[:suggestion][:text])
   end
   render 'create', :layout => false
 end
end
