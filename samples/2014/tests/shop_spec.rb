# == Schema Information
#
# Table name: shops
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  start_at    :datetime
#  end_at      :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  discount    :decimal(8, 2)    default(0.0), not null
#  slug :string(255)
#

require "spec_helper"

describe Shop do

  let(:shop) { Shop.make! }
  let(:designer1) { Designer.make! }
  let(:designer2) { Designer.make! }
  let(:exclusive1) { Exclusive.make!(designer: designer1) }
  let(:exclusive2) { Exclusive.make!(designer: designer2) }
  let(:exclusive5) { Exclusive.make!(designer: designer2) }
  let(:exclusive6) { Exclusive.make!(designer: designer2) }
  let(:exclusive3) { Exclusive.make!(designer: designer2, status: 'close') }
  let(:exclusive4) { Exclusive.make!(designer: designer2,
                                     start_at: Time.now - 10.days,
                                     end_at: Time.now - 20.days
                                     ) }

  describe "#started?" do
    subject { shop }

    context "before it has started" do
      before { shop.update_attributes(:start_at => 1.week.from_now, :end_at => 2.weeks.from_now) }
      it { should_not be_started }
    end

    context "after it has started" do
      before { shop.update_attributes(:start_at => 1.week.ago, :end_at => 1.week.from_now) }
      it { should be_started }
    end

    context "after it has ended" do
      before { shop.update_attributes(:start_at => 2.weeks.ago, :end_at => 1.week.ago) }
      it { should_not be_started }
    end
  end

  describe "#current_exclusives" do
    before{
      shop.shop_exclusives.create exclusive: exclusive1, position: 2
      shop.shop_exclusives.create exclusive: exclusive2, position: 1
      shop.shop_exclusives.create exclusive: exclusive3, position: 0
      shop.shop_exclusives.create exclusive: exclusive4, position: 3
    }
    it "should return exclusives with sorting by position" do
      shop.current_exclusives.should eq([exclusive2, exclusive1])
    end

    it "should not return close exclusive" do
      shop.current_exclusives.should_not include(exclusive3)
    end

    it "should not return not started exclusive" do
      shop.current_exclusives.should_not include(exclusive4)
    end

  end
  describe ".current_exclusives" do
    it "returns all exclusives" do
      shop.exclusives << exclusive1
      shop.exclusives << exclusive2

      Shop.current_exclusives.should == [exclusive1, exclusive2]
    end
  end

  describe "#update_exclusive_positions!" do
    before{
      shop.exclusives << exclusive1
      shop.exclusives << exclusive2
      shop.exclusives << exclusive5
      shop.exclusives << exclusive6
      shop.shop_exclusives.each_with_index{|item, i| item.update_attribute(:position, i)}
    }

    context "when moving to a lower position" do
      it "should return ordered exclusives" do
        shop.update_exclusive_positions!([exclusive1.id, exclusive2.id, exclusive5.id, exclusive6.id],
                                         [exclusive1.id, exclusive2.id, exclusive6.id, exclusive5.id],
                                         exclusive5.id)
        shop.current_exclusives.reload.map(&:id).should eq([exclusive1.id, exclusive2.id, exclusive6.id, exclusive5.id])
      end
    end

  end

  describe "#switch_state" do
    subject { shop }

    context "when it has already started" do
      before do
        shop.update_attributes(:start_at => 1.week.from_now, :end_at => 3.weeks.from_now)
        exclusive1.update_column :show_in_boutique, true
        shop.exclusives << exclusive1
        Timecop.travel 2.weeks.from_now
      end

      it "should also remove exclusives from the boutique" do
        shop.switch_state
        shop.updated_at.should > 1.second.ago
        shop.exclusives.reload.map(&:show_in_boutique).should == [false]
      end

      it "should flush exclusives cache" do
        Timecop.travel 1.hour.from_now
        shop.switch_state
        shop.exclusives.reload.all? {|e| e.updated_at > 1.minute.ago}
      end
    end

    context "when it has already ended" do
      before do
        shop.update_attributes(:start_at => 1.week.from_now, :end_at => 3.weeks.from_now)
        exclusive1.update_column :show_in_boutique, false
        shop.exclusives << exclusive1
        Timecop.travel 4.weeks.from_now
      end

      it "should also remove exclusives from the boutique" do
        shop.switch_state
        shop.updated_at.should > 1.second.ago
        shop.exclusives.reload.map(&:show_in_boutique).should == [true]
      end

      it "should flush exclusives cache" do
        Timecop.travel 1.hour.from_now
        shop.switch_state
        shop.exclusives.reload.all? {|e| e.updated_at > 1.minute.ago}
      end
    end

  end

  describe "#sort_exclusive_ids" do
    before{
      shop.exclusives << exclusive1
      shop.exclusives << exclusive2
      shop.exclusives << exclusive5
      shop.exclusives << exclusive6
      shop.shop_exclusives.each_with_index{|item, i| item.update_attribute(:position, i)}
      shop.update_exclusive_positions!([exclusive1.id, exclusive2.id, exclusive5.id, exclusive6.id],
                                       [exclusive1.id, exclusive2.id, exclusive6.id, exclusive5.id],
                                       exclusive5.id)
    }
    it "should return list exclusive" do
      shop.shop_exclusives.sort_exclusive_ids.should eq([1, 2, 4, 3])
    end
  end
end
