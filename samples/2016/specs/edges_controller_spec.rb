require 'rails_helper'

describe Gazeta::EdgesController do
  let(:current_user) { create(:user) }
  before { sign_in current_user }

  describe 'POST #bind_rubric_subject' do
    let(:rubric) { create :rubric }
    let(:old_subject) { create :subject }
    let(:new_subject) { create :subject }

    subject { rubric.reload.subject }

    context 'rubric with subject' do
      it 'replaces subject' do
        post :bind_rubric_subject, rubric_id: rubric.id, subject_id: new_subject.id
        expect(subject).to eq(new_subject)
      end
      it 'removes subject' do
        post :bind_rubric_subject, rubric_id: rubric.id, subject_id: nil
        expect(subject).to eq(nil)
      end
    end

    context 'rubric without subject' do
      before { rubric.update subject: old_subject }
      before { post :bind_rubric_subject, rubric_id: rubric.id, subject_id: new_subject.id }
      it { is_expected.to eq(new_subject) }
    end
  end

  describe 'GET #index_rubric_subject' do
    let(:title) { 'Кризис в Донбассе' }
    let(:donbass_subject) { create :gazeta_tags_subject, title: title }
    let!(:social) { create :rubric, slug: 'social', subject: donbass_subject }
    let!(:culture) { create :rubric, slug: 'culture' }

    before { get :index_rubric_subject, format: :json }
    subject { parsed_body }
    it { is_expected.to include(hash_including(slug: 'social', subject: hash_including(title: title))) }
    it { is_expected.to include(hash_including(slug: 'culture', subject: nil)) }
  end
end
