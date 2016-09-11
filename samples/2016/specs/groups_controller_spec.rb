require 'rails_helper'

describe Plugins::Interview::GroupsController do
  let(:current_user) { create :user }
  before { sign_in current_user }
  let(:interview) { create :plugin_interview }

  describe 'GET #index' do
    let(:state) { '' }

    before do
      create_list :interview_group, 2, :created, interview: interview
      create_list :interview_group, 3, :published, interview: interview
      get :index, interview_id: interview.id, state: state
    end

    describe 'filtering (array size)' do
      subject { parsed_body.count }

      context 'when ?state=created' do
        let(:state) { :created }
        it { is_expected.to eq(2) }
      end

      context 'when ?state=published' do
        let(:state) { :published }
        it { is_expected.to eq(3) }
      end

      context 'when wrong state' do
        let(:state) { :putin }
        it { is_expected.to eq(0) }
      end

      context 'when empty state' do
        it 'returns all records' do
          expect(parsed_body.count).to eq(5)
        end
      end
    end
  end

  describe 'POST #create' do
    let(:group_attributes) do
      { name: 'Война в Донбассе', position: 1, state: 'created', interview_id: interview.id }
    end

    before { post :create, group_attributes }

    describe 'response' do
      subject { response }
      it { is_expected.to have_http_status(:created) }
    end

    context 'when valid attributes' do
      describe 'body' do
        subject { parsed_body }
        it { is_expected.to include(:name, :interview_id, :state, :position) }
      end
    end

    context 'when invalid attributes' do
      let(:group_attributes) { { interview_id: interview.id } }
      describe 'errors' do
        subject { parsed_body[:errors] }
        it { is_expected.to include('position') }
        it { is_expected.to include('state') }
      end
    end
  end

  describe 'GET #show' do
    let(:group) { create :interview_group, interview: interview }
    before { get :show, interview_id: interview.id, id: group.id }

    describe 'response body' do
      subject { parsed_body }
      it { is_expected.to include('name': group.name) }
      it { is_expected.to include('interview_id': interview.id) }
      it { is_expected.to include('position') }
      it { is_expected.to include('state') }
    end
  end

  describe 'PUT #update' do
    let(:group) { create :interview_group, interview: interview }
    let(:question) { 'Когда повысят зарплату?' }

    context 'when valid' do
      describe 'response body' do
        before { put :update, interview_id: interview.id, id: group.id, name: question }
        it { expect(response).to have_http_status(:ok) }

        before { get :show, interview_id: interview.id, id: group.id }
        subject { parsed_body }
        it { is_expected.to include('name': question) }
      end
    end

    context 'when invalid' do
      before { put :update, interview_id: interview.id, id: group.id, state: 'unknown' }
      it { expect(response).to have_http_status(:unprocessable_entity) }
    end
  end

  describe 'DELETE #destroy' do
    let(:group) { create :interview_group, interview: interview }
    before { delete :destroy, interview_id: interview.id, id: group.id }
    it { expect(response).to have_http_status(:no_content) }
  end
end
