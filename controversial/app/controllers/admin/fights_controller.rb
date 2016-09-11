class Admin::FightsController < AdminController
  def index
    @fights = Fight.all(:order=>'votes desc')    
  end

  def new
    @fight = Fight.create
    redirect_to "/admin/fights/#{@fight.id}/edit"
  end

  def edit
    @fight = Fight.find(params[:id])
  end

  def create
    @fight = Fight.new(params[:fight])
    @fight.title = "#{params[:brand1]} vs. #{params[:brand2]}"
    @fight.slug = @fight.title.downcase.gsub(/[^[:alnum:]]/,'-').gsub(/-{2,}/,'-')
    
    r1=Brand.new(:fight=>@fight, 
                  :img=>params[:img1], 
                  :avatar=>params[:avatar1],
                  :votes_stored=>params[:votes1].blank? ? 0 : params[:votes1]).save
                  
    r2=Brand.new(:fight=>@fight, 
                  :img=>params[:img2], 
                  :avatar=>params[:avatar2],
                  :votes_stored=>params[:votes2].blank? ? 0 : params[:votes2]).save
                  
    respond_to do |format|
      
      if r1 && r2 && @fight.save
        format.html { redirect_to(admin_fights_path, :notice => 'Fight was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @fight = Fight.find(params[:id])
    @fight.update_attributes(params[:fight])
    redirect_to '/admin'
  end

  def destroy
    @fight = Fight.find(params[:id])
    @fight.destroy

    respond_to do |format|
      format.html { redirect_to(admin_fights_path) }
    end
  end
end
