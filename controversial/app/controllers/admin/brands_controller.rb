class Admin::BrandsController < AdminController
  def edit
    @brand=Brand.find(params[:id])
  end
  
  def update
    @brand=Brand.find(params[:id])
    if @brand.update_attributes(params[:brand])
        redirect_to(admin_fights_path)
    else
        render :text => "error"
    end
  end
end