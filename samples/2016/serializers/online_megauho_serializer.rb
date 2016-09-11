class Dispatch::Sport::OnlineMegauhoSerializer < ActiveModel::Serializer
  attributes :score, :score_overtime, :status, :tournament, :link, :start_at
  attribute championat_state: :state

  has_one :tournament, serializer: Dispatch::Sport::TournamentMegauhoSerializer

  def tournament
    object.tournaments.first
  end

  def start_at
    Time.zone.parse("#{object.date} #{object.time}").utc
  end

  def score
    object.live_result.try(:first)
  end

  # FIXME: have to count by hands
  def score_overtime?
    # object.live_result.try(:count).to_i > 1
    false
  end

  def score_overtime
    # object.live_result.try(:last) if score_overtime?
    nil
  end

  2.times do |i|
    attributes(*["name#{i + 1}", "logo#{i + 1}", "icon#{i + 1}"].map(&:to_sym))

    define_method "name#{i + 1}" do
      object.teams[i].try(:title) unless object.teams.empty?
    end

    define_method "logo#{i + 1}" do
      object.teams[i].try(:logo) unless object.teams.empty?
    end

    define_method "icon#{i + 1}" do
      object.teams[i].try(:icon) unless object.teams.empty?
    end
  end
end
