require 'spec_helper'

describe Exclusive, user_email: false do
  describe 'update price in shopping bag' do
    let!(:bag1) { ShoppingBag.make!(purchased: false) }
    let!(:bag2) { ShoppingBag.make!(purchased: false) }
    let!(:category) { Category.make! }
    let!(:exclusive) do
      Exclusive.make!(price: 100.0, categories: [category])
    end
    before do
      ShoppingBagAddProduct.run(bag: bag1, exclusive_id: exclusive.id)
      ShoppingBagAddProduct.run(bag: bag2, exclusive_id: exclusive.id)
      bag2.update_attribute(:purchased, true)
    end
    it 'should update price in unpurchased basket' do
      expect do
        exclusive.price = 175
        exclusive.save!
      end.to change { bag1.shopping_bag_exclusives.reload.first.price }.to(175)
    end
    it 'should not update price in purchased basket' do
      expect do
        exclusive.price = 175
        exclusive.save!
      end.to_not change { bag2.shopping_bag_exclusives.first.price }
    end
  end

  describe '#duplicate' do
    let(:category) { Category.make! }
    let(:exclusive) do
      Exclusive.make!(price: 100.0,
                      categories: [category],
                      meta_data: MetaData.make)
    end
    it 'should copy exclusive' do

      copy_exclusive = exclusive.duplicate
      copy_exclusive.categories.should eq([category])
      copy_exclusive.meta_data.title.should eq(exclusive.meta_data.title)
      copy_exclusive.meta_data.keywords.should eq(exclusive.meta_data.keywords)
      copy_exclusive.meta_data.description.should eq(exclusive.meta_data.description)
    end
  end

  describe 'allow mass assignment' do
    it { should allow_mass_assignment_of(:delivery_and_returns) }
  end

  describe '#quantity=' do
    context 'when new product' do
      it 'should save quantity' do
        @exclusive = Exclusive.create!(title: 'Test',
                                       price: 1,
                                       start_at: Time.now,
                                       end_at: (Time.now + 1.month),
                                       lead_time: 'In Stock',
                                       quantity: 6)
        @exclusive.in_stock.should eq(6)
      end
    end

    context 'when valus is not number' do
      subject { Exclusive.make!(maximum_quantity: 19) }
      it 'should set quantity to nil' do
        expect do
          subject.update_attribute(:quantity, '')
        end.to change { subject.maximum_quantity }.to(nil)
      end
    end

    context 'when value is number' do
      subject { Exclusive.make!(maximum_quantity: 19) }
      context 'and value is zero' do
        context 'and has not purchases' do
          it 'should set quantity to zero' do
            expect do
              subject.update_attribute(:quantity, 0)
            end.to change { subject.maximum_quantity }.to(0)
          end
        end
        context 'and has purchases' do
          before { subject.stub(:purchase_count).and_return(9) }
          it 'should set left to zero' do
            expect do
              subject.update_attribute(:quantity, 0)
            end.to change { subject.maximum_quantity }.to(9)
            subject.left.should be_zero
          end
        end
      end

      context 'when value is greater than at in stock' do
        context 'and has not purchases' do
          it 'should set quantity to new value' do
            expect do
              subject.update_attribute(:quantity, 22)
            end.to change { subject.maximum_quantity }.to(22)
            subject.left.should eq(22)
          end

        end
        context 'and has purchases' do
          before { subject.stub(:purchase_count).and_return(9) }
          it 'should set quantity to new value with pucrhases count' do
            expect do
              subject.update_attribute(:quantity, 22)
            end.to change { subject.maximum_quantity }.to(31)
            subject.left.should eq(22)
          end
        end
      end

      context 'when value is less than at in stock' do
        context 'and has not purchases' do
          it 'should set quantity to new value' do
            expect do
              subject.update_attribute(:quantity, 7)
            end.to change { subject.maximum_quantity }.to(7)
            subject.left.should eq(7)
          end

        end
        context 'and has purchases' do
          before { subject.stub(:purchase_count).and_return(9) }
          it 'should set quantity to new value with pucrhases count' do
            expect do
              subject.update_attribute(:quantity, 7)
            end.to change { subject.maximum_quantity }.to(16)
            subject.left.should eq(7)
          end
        end
      end

    end
  end

  describe "#set_breadcrumbs_category" do
    let(:exclusive) { Exclusive.make! }
    subject { exclusive.breadcrumbs_category }
    context "when exclusive belongs to several categories" do
      it "should be nil" do
        category1 = Category.make! name: 'FOR HER'
        category2 = Category.make! name: 'BAGS', parent: category1
        category3 = Category.make! name: 'LEATHER', parent: category2
        exclusive.categories = [category2, category3]
        exclusive.save
        exclusive.reload
        should == 'FOR HER > BAGS > LEATHER'
      end
    end
    context "when exclusive has no categories" do
      it "should be nil" do
        should be_blank
      end
    end
  end

  describe '#unlimited_in_stock?' do
    let(:exclusive) { Exclusive.make! :price => 100.0 }

    context 'without option' do
      subject { exclusive.unlimited_in_stock? }
      context 'when maximum_quantity is nil' do
        before { exclusive.update_attribute(:maximum_quantity, nil) }
        it { should be_true }
      end

      context 'when maximum_quantity not is nil' do
        before { exclusive.update_attribute(:maximum_quantity, 10) }
        it { should be_false }
      end
    end
    context 'with option' do

    end
  end
  describe "#purchase_count" do
    let(:exclusive) { Exclusive.make! :price => 100.0 }
    let(:user) { User.make! }
    let(:shopping_bag) { ShoppingBag.make! user: user }
    let(:shopping_bag1) { ShoppingBag.make! user: user }
    before do
      ShoppingBagAddProduct.run(bag: shopping_bag, exclusive_id: exclusive.id)
      ShoppingBagAddProduct.run(bag: shopping_bag, exclusive_id: exclusive.id)
      shopping_bag.update_attribute(:purchased, true)

      @option = exclusive.options.create(quantity: 2, choices: %w(Small Red))
      ShoppingBagAddProduct.run(bag: shopping_bag1,
                                exclusive_id: exclusive.id,
                                option_id: @option.id)
      ShoppingBagAddProduct.run(bag: shopping_bag1,
                                exclusive_id: exclusive.id,
                                option_id: @option.id)
      shopping_bag1.update_attribute(:purchased, true)
    end

    context 'with option' do
      it 'should return all purchase count for option' do
        exclusive.purchase_count(@option).should eq(2)
      end
    end
    context 'without option' do
      it 'should return all purchase count' do
        exclusive.purchase_count.should eq(4)
      end
    end
  end

  describe "#left_less?" do
    let(:exclusive) { Exclusive.make! :price => 100.0 }
    subject{ exclusive }
    context "when available qty between 0..value" do
      before{exclusive.stub(left: 2) }
      it "should be true" do
        subject.left_less?(3).should be_true
      end
    end
    context "when available qty 0 " do
      before{exclusive.stub(left: 0) }
      it "should be false" do
        subject.left_less?(3).should be_false
      end
    end
    context "when available qty greater than " do
      before{exclusive.stub(left: 10) }
      it "should be false" do
        subject.left_less?(3).should be_false
      end
    end
  end

  describe '#left_less_with_option?' do
    let(:exclusive) { Exclusive.make! :price => 100.0 }
    let(:options) { %w(Small Red) }
    subject{ exclusive }

    context 'when available qty for option between 0..value' do
      before{ @option = exclusive.options.create(quantity: 2, choices: options) }
      it 'should be true' do
        subject.left_less_with_option?(3, @option).should be_true
      end
    end

    context 'when available qty 0' do
      before{ @option = exclusive.options.create(quantity: 0, choices: options)}
      it 'should be false' do
        subject.left_less_with_option?(3, @option).should be_false
      end
    end
    context 'when available qty greater than' do
      before{ @option = exclusive.options.create(quantity: 10, choices: options) }
      it 'should be false' do
        subject.left_less_with_option?(3, @option).should be_false
      end
    end

  end

  describe "#left_with_option" do
    let(:exclusive) { Exclusive.make! :price => 100.0 }
    before{
      @option = exclusive.options.create(quantity: 2, choices: ["Small", "Red" ])
    }
    context "when available qty is nil" do
      before{ exclusive.stub(quantity_available: nil) }
      it "should be nil" do
        exclusive.left_with_option(@option).should be_nil
      end
    end
    context "when available qty is not nil" do
      before{ exclusive.stub(quantity_available: 7,  purchase_count: 5) }
      it "should return available qty" do
        exclusive.left_with_option(@option).should eq(2)
      end
    end
  end

  describe "#display_discount?" do
    let(:start_period){
      { start_at: (Time.now - 10.days),  end_at: (Time.now + 10.days),}
    }

    let(:exclusive) { Exclusive.make! :price => 100.0 }
    let(:shop) { Shop.make!({display_discount: true}.merge(start_period)) }
    let(:shop1) { Shop.make!({display_discount: false}.merge(start_period)) }
    context "when unchecked 'display discount' in shop settings " do
      it "should be false" do
        exclusive.shops << shop1
        exclusive.display_discount?.should be_false
      end
    end
    context "when checked 'display discount' in shop settings " do
      it "should be true" do
        exclusive.shops << shop
        exclusive.display_discount?.should be_true
      end
    end

    context "when exculise without shop" do
      it "should be true" do
        exclusive.display_discount?.should be_true
      end
    end
  end

  describe "#max_in_stock" do
    let(:exclusive) { Exclusive.make! :price => 100.0 }
    context "when the exclusive are sold" do
      it "should return zero" do
        exclusive.stub(:sold_out? => true)
        exclusive.max_in_stock.should eq(0)
      end
    end
    context "when the exclusive are not sold" do
      it "should return available qty of exclusive" do
        exclusive.stub(:quantity_available => 10)
        exclusive.stub(:purchase_count => 0)
        exclusive.max_in_stock.should eq(10)
      end
    end
  end

  describe "#in_stock?" do
    let(:exclusive) { Exclusive.make! :price => 100.0 }
    context "when qty is undefined" do
      it "should be true" do
        exclusive.stub(:quantity_available => nil)
        exclusive.in_stock?(1).should be_true
      end
    end
    context "when the exclusive are sold" do
      it "should be false" do
        exclusive.stub(maximum_quantity: 10, sold_out?: true)
        exclusive.in_stock?(1).should be_false
      end
    end
    context "when the exclusive are in stock" do
      context "and exclusive qty is available" do
        it "should be true" do
          exclusive.stub(maximum_quantity: 10, sold_out?: false, purchase_count: 3)
          exclusive.in_stock?(5).should be_true
        end
      end
      context "and exclusive qty is not available" do
        it "should be false" do
          exclusive.stub(maximum_quantity: 10, sold_out?: false, purchase_count: 3)
          exclusive.in_stock?(8).should be_false
        end
      end
    end
  end

  describe '#current_price' do
    let(:exclusive) { Exclusive.make! :price => 100.0 }

    context 'with a shop discount' do
      let(:shop) { Shop.make!(:discount => 20) }

      before do
        shop.exclusives << exclusive
      end

      it 'uses the discount when the shop is active' do
        shop.update_attributes(:start_at => 1.day.ago, :end_at => 1.days.from_now)
        exclusive.current_price.should == 80.0
      end

      it 'ignores the discount when the shop is not active' do
        shop.update_attributes(:start_at => 1.day.from_now, :end_at => 2.days.from_now)
        exclusive.current_price.should == 100.0
      end
    end

  end

  describe '#first_two_days?' do
    it "is true when event has just started" do
      Exclusive.make(:start_at => 1.minute.ago).should be_first_two_days
    end

    it "is true when the event has been going just under 48 hours" do
      Exclusive.make(:start_at => 46.hours.ago).should be_first_two_days
    end

    it "is false when the event has been doing just over 48 hours" do
      Exclusive.make(:start_at => 48.hours.ago).should_not be_first_two_days
    end

    it "is false if the event has finished before 48 hours has passed" do
      Exclusive.make(:start_at => 12.hours.ago, :end_at => 4.hours.ago).
        should_not be_first_two_days
    end
  end

  describe "#quantity_available" do
    let(:exclusive) { Exclusive.make! }

    it "returns false when there's no maximum quantity and there are no options" do
      exclusive.quantity_available.should be_false
    end

    it "returns the sum of the quantities for each option if there are options with quantities" do
      exclusive.options.create(:quantity => 2, :choices => ["Small", "Red" ])
      exclusive.options.create(:quantity => 4, :choices => ["Medium", "Red" ])
      exclusive.quantity_available.should == 6
    end

    it "returns the maximum quantity if there are options without quantities" do
      exclusive.options.create(:choices => ["Small", "Red" ])
      exclusive.options.create(:choices => ["Medium", "Red" ])
      exclusive.maximum_quantity = 10
      exclusive.quantity_available.should == 10
    end
    context "with option " do
      it "should return available qty for option" do
        option = exclusive.options.create(quantity: 2, choices: ["Small", "Red" ])
        exclusive.options.create(quantity: 4, choices: ["Medium", "Red" ])
        exclusive.quantity_available(option).should eq(2)
      end
    end
  end

  describe '#sold_out?' do
    let(:exclusive) { Exclusive.make! }

    it 'returns false when there the quantity available is not set' do
      exclusive.stub(:quantity_available => nil)
      exclusive.should_not be_sold_out
    end

    it 'returns false when the number of purchases is less than the quantity available' do
      exclusive.stub(maximum_quantity: 2)
      exclusive.should_receive(:purchase_count).and_return(1)
      exclusive.should_not be_sold_out
    end

    it 'returns true when the number of purchases equals the quantity available' do
      exclusive.stub(maximum_quantity: 2)
      exclusive.should_receive(:purchase_count).and_return(2)
      exclusive.should be_sold_out
    end

    it "returns true when the number of purchases is greater than the quantity available" do
      exclusive.stub(maximum_quantity: 2)
      exclusive.should_receive(:purchase_count).and_return(3)
      exclusive.should be_sold_out
    end
  end

  describe '#valid?' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:start_at) }
    it { should validate_presence_of(:end_at) }
    it { should validate_presence_of(:price) }
    context 'for regular exclusive' do
      it { should validate_numericality_of(:price).is_greater_than(0) }
    end
    context 'for gift cards' do
      subject { Exclusive.make(:gift_card) }
      it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    end

  end

  describe 'validation gift card' do

    context 'if exclusive used as gift card' do
      before { subject.stub(:gift_card?) { true } }
      it { should validate_presence_of(:gift_card_kind) }
    end

    context 'if exclusive not used as gift card' do
      before { subject.stub(:gift_card?) { false } }
      it { should_not validate_presence_of(:gift_card_kind) }
    end

  end

  describe 'kind  of gift card' do
    before { subject.stub(:gift_card?) { true } }
    describe '#gift_card_is_regular?' do
      before { subject.stub(:gift_card_kind) { GiftCard::REGULAR } }
      context 'when used as regular gift card' do
        its(:gift_card_is_regular?) { should be_true }
      end
    end

    describe '#gift_card_is_virtual?' do
      before { subject.stub(:gift_card_kind) { GiftCard::VIRTUAL } }
      context 'when used as virtual gift card' do
        its(:gift_card_is_virtual?) { should be_true }
      end
    end
  end

  it { should allow_mass_assignment_of(:gift_card) }
  it { should allow_mass_assignment_of(:gift_card_kind) }
end
