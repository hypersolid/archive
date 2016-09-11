require 'rails_helper'

describe Topics::TopicsController do
  include ActiveJob::TestHelper

  routes { Topics::Engine.routes }

  let(:current_user) { create :user }
  let(:topic_attributes) { attributes_for(:gazeta_topics_article) }

  before { sign_in current_user }

  describe 'POST #create' do
    context 'with valid attributes' do
      before { post :create, topic: topic_attributes, format: :json }
      it { expect(response).to have_http_status(:created) }
    end

    context 'when rubric_id present' do
      let(:topic_attributes) do
        attributes_for(:gazeta_topics_article)
      end
      let(:rubric) { create :rubric }
      before { post :create, rubric_id: rubric.id, topic: topic_attributes, format: :json }
      subject { parsed_body }
      it { is_expected.to include('rubric_id' => rubric.id) }
    end

    context 'when subrubric_id present' do
      let(:subrubric) { create :gazeta_tags_subrubric }
      let(:topic_attributes) do
        attributes_for(:gazeta_topics_article).merge(subrubric_id: subrubric.id)
      end
      before { post :create, topic_attributes, format: :json }
      subject { parsed_body }
      it { is_expected.to include('subrubric_id' => subrubric.id) }
    end

    context 'when Article' do
      before { post :create, topic: topic_attributes, format: :json }
      it { expect(response).to have_http_status(:created) }
    end

    describe 'Topics::Infographic' do
      let(:new_topic_title) { 'New Title' }

      context 'when frame_content provided' do
        let(:infographic_attributes) do
          topic_attributes.merge(type: 'Gazeta::Topics::Infographic',
                                 infographic_attributes: {
                                   frame_content: 'frame_content' })
        end
        it 'creates topic with infographics plugin' do
          expect do
            post :create, infographic_attributes
          end.to change {
            Gazeta::Plugins::Infographic.count
          }.by(1)
          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          infographic = Gazeta::Topics::Infographic.find(json_response['id'])
          expect(infographic.infographic).to be
        end
      end

      context 'when picture_id provided' do
        let(:picture) { create :infographic_picture }
        let(:infographic_attributes) do
          topic_attributes.merge(type: 'Gazeta::Topics::Infographic',
                                 infographic_attributes: {
                                   picture_id: picture.id })
        end

        it 'creates topic with infographics plugin' do
          expect do
            post :create, infographic_attributes
          end.to change {
            Gazeta::Plugins::Infographic.count
          }.by(1)

          expect(response).to have_http_status(:created)
          infographic = Gazeta::Topics::Infographic.find(parsed_body['id'])
          expect(infographic.infographic).to be
        end
      end
    end

    describe 'Topics::Video' do
      let(:video_attributes) do
        video_plugin_attributes = { provider: 'youtube', provider_token: 'PewF8pZBXSo' }
        topic_attributes.merge(type: 'Gazeta::Topics::Video', video_attributes: video_plugin_attributes)
      end

      it 'creates video plugin' do
        expect { post :create, video_attributes }.to change { Gazeta::Plugins::Video.count }.by(1)
        expect(response).to have_http_status(:created)
      end

      it 'creates video plugin inside video topic' do
        post :create, video_attributes
        video_topic = Gazeta::Topics::Video.find(parsed_body['id'])
        expect(video_topic.video).to be
      end
    end

    describe 'Topics::Sport::Online' do
      let(:online_attributes) do
        topic_attributes.merge(type: 'Gazeta::Topics::Sport::Online',
                               broadcast_attributes: {})
      end

      it 'creates a broadcast plugin' do
        expect { post :create, online_attributes }
          .to change { Gazeta::Plugins::Broadcast.count }.by(1)
        expect(response).to have_http_status(:created)
        expect(parsed_body).to include(broadcast: hash_including(:id))
      end
    end
  end

  describe 'PUT #update' do
    context 'when legacy topic' do
      let!(:topic) { create :gazeta_topics_article, :legacy }
      before { put :update, id: topic.id, topic: { headline: 'new title' }, format: :json }
      it { expect(response).to have_http_status(:forbidden) }
    end

    describe 'Topics::Article' do
      let!(:topic) { create :gazeta_topics_article, :published }
      let(:new_topic_title) { 'New Title' }

      it 'updates topics headline and responds with HTTP_OK' do
        expect_any_instance_of(Gazeta::TopicDispatcher).to receive(:dispatch).once
        put :update, id: topic.id, topic: { headline: new_topic_title }, format: :json
        expect(response).to have_http_status(:ok)
        expect(topic.reload.headline).to eq(new_topic_title)
      end

      it 'assigns new value of exclusive attribute' do
        topic.update_attribute(:exclusive, false)

        expect do
          put :update, id: topic.id, topic: topic_attributes.merge(exclusive: true), type: topic.class.to_s, format: :json
        end.to change {
          topic.reload.exclusive
        }.from(false).to(true)
      end

      context 'when rubric_id present' do
        let(:rubric) { create :rubric }
        before { put :update, id: topic.id, rubric_id: rubric.id, topic: topic.attributes, format: :json }
        it 'updates rubric' do
          json_response = JSON.parse(response.body)
          expect(json_response['rubric_id']).to eq(rubric.id)
        end
      end

      context 'when subrubric_id present' do
        let(:subrubric) { create :gazeta_tags_subrubric }
        before do
          put :update,             id: topic.id,
                                   subrubric_id: subrubric.id,
                                   topic: topic.attributes,
                                   type: topic.type,
                                   format: :json
        end
        it 'updates subrubric' do
          json_response = JSON.parse(response.body)
          expect(json_response['subrubric_id']).to eq(subrubric.id)
        end
      end
    end

    describe 'Topics::Infographic' do
      let!(:topic) { create :gazeta_topics_infographic }

      context 'when frame_content provided' do
        let(:infographic_attributes) do
          topic.attributes.merge(infographic_attributes: { frame_content: '' })
        end

        before { put :update, infographic_attributes }

        it 'creates topic with infographics plugin' do
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['infographic']['frame_content']).to eq('')
        end
      end
    end

    describe 'Topics::News' do
      let!(:topic) { create :gazeta_topics_news }

      it 'assigns new value of main attribute (for News)' do
        topic.update_attribute(:main, false)

        expect do
          put :update, id: topic.id, topic: topic_attributes.merge(main: true), type: topic.class.to_s, format: :json
        end.to change {
          topic.reload.main
        }.from(false).to(true)
      end
    end

    describe 'Topics::Video' do
      let!(:topic) { create :gazeta_topics_video }

      context 'when attributes valid' do
        let(:video_attributes) do
          topic.attributes.merge(video_attributes: { provider: 'youtube', provider_token: 'updated_token' })
        end

        before { put :update, video_attributes }

        it 'updates video plugin' do
          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response['video']['provider_token']).to eq('updated_token')
        end
      end
    end
  end
end
