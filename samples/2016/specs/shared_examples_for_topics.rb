require 'rails_helper'

shared_examples 'Topic' do
  it { is_expected.to have_many(:tags) }
  it { is_expected.to have_many(:gazeta_tags) }
  it { is_expected.to have_many(:specprojects) }
  it { is_expected.to have_many(:subjects) }

  it { is_expected.to have_many(:widgets) }

  it { is_expected.to respond_to :picture }

  let(:factory) { factory_by_model described_class }

  describe '.metadata' do
    subject(:metadata) { described_class.metadata }
    context '[:acceptable_tags]' do
      subject { metadata[:acceptable_tags] }
      it { is_expected.to include(Gazeta::Topic::BASE_TAGS_METADATA) }
    end
    context '[:sport]' do
      subject { metadata[:sport] }
      it { is_expected.to eq(true).or(eq(false)) }
    end
  end
end

shared_examples 'topic with dispatcher' do |dispatcher_class|
  describe '.dispatcher_class' do
    subject { described_class.dispatcher_class }
    it { is_expected.to eq(dispatcher_class) }
  end

  describe '#dispatcher_class' do
    subject { described_class.new.dispatcher_class }
    it { is_expected.to eq(dispatcher_class) }
  end
end

shared_examples 'topic with serializer' do |serializer_class|
  describe '#dispatcher_class' do
    subject { described_class.new.active_model_serializer }
    it { is_expected.to eq(serializer_class) }
  end
end
