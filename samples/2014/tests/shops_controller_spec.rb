require 'spec_helper'

describe ShopsController do

  describe "#show" do
    context "when shop hasn't started yet" do
      let(:shop) { Shop.make!(start_at: 5.days.from_now,  end_at: 10.days.from_now)}

      it "redirects to the preview" do
        ShopsController.any_instance.stub(:admin_signed_in?) { true }
        get :show, :id => shop.id
        response.should redirect_to(preview_shop_path(shop))
      end
    end

    context "when shop is active" do
      let(:shop) { Shop.make!(start_at: 10.days.ago,  end_at: 10.days.from_now) }

      it "redirects to the preview" do
        get :show, :id => shop.id
        should respond_with(:success)
        should render_template(:show)
      end
    end

    context "when shop has ended" do
      let(:designer) { Designer.make! }
      let(:shop) { Shop.make!(start_at: 10.days.ago,  end_at: 5.days.ago) }

      it "redirects to the home page" do
        get :show, :id => shop.id
        response.should redirect_to(root_path)
      end

      it "redirects to the designer's page if designer is present" do
        shop.update_attribute :designer, designer
        get :show, :id => shop.id
        response.should redirect_to(designer_path(designer))
      end
    end

    context "when shop is closed" do
      let(:designer) { Designer.make! }
      let(:shop) { Shop.make!(start_at: 10.days.ago,  end_at: 10.days.from_now) }

      it "redirects to the home page" do
        shop.close
        get :show, :id => shop.id
        response.should redirect_to(root_path)
      end

      it "redirects to the designer's page if designer is present" do
        shop.update_attribute :designer, designer
        shop.close
        get :show, :id => shop.id
        response.should redirect_to(designer_path(designer))
      end
    end
    
    context "when was deleted" do
      let(:designer) { Designer.make! }
      let(:shop) { Shop.make!(start_at: 10.days.ago,  end_at: 10.days.from_now) }

      it "redirects to the home page" do
        shop.destroy
        get :show, :id => shop.id
        response.should redirect_to(root_path)
      end

      it "redirects to the designer's page if designer is present" do
        shop.update_attribute :designer, designer
        shop.destroy
        get :show, :id => shop.id
        response.should redirect_to(designer_path(designer))
      end
    end

 end
end