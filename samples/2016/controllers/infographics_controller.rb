class InfographicsController < ApplicationController
  decorates_assigned :infographics, :infographic, :related_links

  layout 'application_dark'

  before_action { @infographic_query = Topics::InfographicQuery.new(:d) }

  def index
    @infographics = @infographic_query.index
    @infographic = infographics.shift
  end

  def index_by_rubric
    @rubric = Rubric.where(slug: params[:rubric]).first

    @infographics = @infographic_query.index_by_rubric(@rubric.slug)
    @infographic = infographics.shift

    render 'index'
  end

  def index_sport
    sport_infographic_query = Topics::Sport::InfographicQuery.new(scope)

    @infographics = sport_infographic_query.index
    @infographic = infographics.shift

    render 'index'
  end

  def show
    @infographic = Topics::Infographic.find_by!(link: link)
    @infographics = @infographic_query.recent(@infographic.link)
  end

  private

  def link
    request.original_fullpath
  end
end
