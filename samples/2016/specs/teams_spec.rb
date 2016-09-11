require 'rails_helper'
require 'webmock'

include WebMock::API

describe Championat::Creators::Teams do
  let(:sport) { create :sport, :football }
  let(:tournament) { create :tournament, parent: sport, championat_id: 1014 }
  subject(:creator) { described_class.new(tournament: tournament) }

  around(:example) do |example|
    VCR.use_cassette(:rfpl_2014_2015_calendar) { example.run }
  end

  before do
    stub_request(:any, %r{http://img\.championat\.com/.*})
  end

  it 'fetches all 16 teams from api' do
    # There are 428 players with statistics in RFPL 2014-2015
    expect { creator.fetch }.to change { creator.teams.size }.to(16)
  end

  it 'creates rubric for each team and sets ancestry' do
    creator.fetch

    expect { creator.store }
      .to change { Gazeta::Tags::Sport::Team.at_depth(2).count }.by(16)

    Gazeta::Tags::Sport::Team
      .pluck(:title, :slug, :championat_id, :params)
      .each { |team| expect(team).to all(be_present) }
  end

  context 'When some rubrics exists' do
    let(:spartak) { create :team, title: 'Спарт', slug: 'spartak', championat_id: 21_104, parent: tournament }

    before { create :team, title: 'Рубин', championat_id: 21_110, parent: tournament }

    it 'updates rubric if team already exists' do
      creator.fetch

      expect { creator.store }
        .to change { Gazeta::Tags::Sport::Team.count }.by(14)
        .and change { spartak.reload.title }.to('Спартак')
      Gazeta::Tags::Sport::Team
        .pluck(:title, :slug, :championat_id, :params)
        .each { |team| expect(team).to all(be_present) }
    end
  end
end
