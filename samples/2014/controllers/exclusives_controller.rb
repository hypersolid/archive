class Shop::ExclusivesController < ApplicationController
  include Shop::ExclusivesHelper

  # workaround for query action caching
  layout :shop_layout

  attr_accessor :exclusive, :exclusives, :image, :shopping_bag_exclusive
  helper_method :exclusive, :exclusives, :image, :shopping_bag_exclusive
  helper_method :designer_filter_path

  caches_action :index, layout: false, cache_path: Proc.new { |c| c.send(:index_cache_path) }
  caches_action :query, layout: false, cache_path: Proc.new { |c| c.send(:query_cache_path) }
  caches_action :show, layout: false, cache_path: Proc.new { |c| c.send(:show_cache_path) }

  def index
    @tree = Category.all
    preprocess

    @meta_source = @category
    @meta_title_prefix = "#{@designers.first.name} | " if @designers.present?
  end

  def show
    @exclusive = @meta_source = Exclusive.with_deleted.find(params[:exclusive_id])

    # routing for obsolete products
    if @exclusive.closed? || @exclusive.ended? || @exclusive.deleted?
      path = @exclusive.designer ? designer_path(@exclusive.designer) : root_path
      redirect_to path and return
    end

    @shopping_bag_exclusive = exclusive.shopping_bag_exclusives.build

    other = exclusive.other_by_designer
    @similar = (other ? other.limit(12) : [])
    @similar_count = (other ? other.count : 0)

    unless request.referer.blank?
      @referer_params = Rails.application.routes.recognize_path(URI(request.referer).path)
      @categories = Category.categories_for_path(@referer_params[:path])
      @qubit_subcategory =
        case @referer_params[:controller].to_s
        when 'shop/exclusives' then 'boutique'
        when 'shops'           then 'popup'
        when 'designers'
          @referer_designer = Designer.find(@referer_params[:id])
          'designer'
        else
          'direct'
        end
    end

    render exclusive_show_template(@exclusive)
  end

  def query
    redirect_to root_url and return unless request.xhr?
    preprocess
    results_data = render_to_string(partial: 'query', format: :html, layout: false)
    respond_to do |format|
      format.html { render layout: false }
      format.json {
        render json: {
          results: results_data,
          designers: @filter_designers.map {|j|
            {
              id: j.id,
              name: j.name,
              slug: j.slug,
              link: shop_exclusives_page_path(@path, designer_filter_path(j, (@designers || [])), @price)
            }
          },
          choose_designers: (@designers || [])
        }
      }
    end
  end

  def search
    @query = preprocess
    @tree = Category.all
    @facet_categories = @query.facet_categories
    render :index
  end

  private

  def shop_layout
    request.xhr? ? "empty" : "application"
  end

  def designer_filter_path(designer, choose_designers)
    list =
      if choose_designers.include?(designer)
        choose_designers.select { |v| v.id != designer.id }.map(&:slug)
      else
        [choose_designers, designer].flatten.map(&:slug)
      end
    (list.empty? ? 'all-designers' : list.uniq.sort.join('_'))
  end

  def preprocess
    ### Prepare params ###
    @path = params[:path] || 'main-page'
    @by = params[:by] || 'all-designers'
    @price = params[:price] || 'newest'
    @offers_filter = params[:offers] || Exclusive::Search::OFFER_FILTERS[:all]

    @per_line = (params[:per_line] || 3).to_i
    @per_page = (params[:per_page] || 12).to_i

    excluded_id = params[:exclude]

    ### Prepare path ###
    @category = nil
    @categories = []

    unless params[:path].blank?
      steps = params[:path].split('_')
      steps.each do |step|
        @category = Category.where(:slug => step, :parent_id => (@category ? @category.id : nil)).first
        @categories << @category
      end
    end

    ### Prepare deigners ###
    @designer_slugs = []
    @designer_ids = []
    if params[:by]
      @designer_slugs = (params[:by].kind_of?(Array) ? params[:by] : params[:by].split('_'))
      @designers = Designer.where(slug: @designer_slugs)
      @designer_ids = @designers.map(&:id)
    end
    @designer_slugs.delete('all-designers')
    @designer_names = @designer_slugs.map{|ds| ds.split('-').map(&:capitalize).join(' ') }.join(', ')

    ### Prepare the order ###
    order_by = 'start_at DESC'
    order_by = (@price == 'high' ? 'price DESC' : 'price ASC') unless @price == 'newest'

    ### Query results ###

    @exclusive_query = Exclusive::Search
      .for_shop(query: params[:q],
                category: @category,
                designer_ids: @designer_ids,
                order_by: order_by,
                all_exclusives: (params[:q].present? ? true : params[:all_exclusives]),
                excluded_id: excluded_id,
                price_range: params[:price_range],
                page: params[:page],
                per_page: @per_page,
                offers: @offers_filter
                )
    @filter_designers =  @exclusive_query.facet_designers
    @exclusives = @exclusive_query.results
    @exclusives_count = @exclusives.total_entries

    @exclusive_query
  end

  def redirect_to_holding
    super unless facebook_request?
  end

  def show_cache_path
    ['shop:show:',
     Digest::MD5.hexdigest([
                            Exclusive.find(params[:exclusive_id]).cache_key,
                            Exclusive.find(params[:exclusive_id]).designer.cache_key,
                            user_signed_in?, request.host,
                            request.referrer, Currency.current].join)
    ].join
  end

  def index_cache_path
    ['shop:index:',
     Digest::MD5.hexdigest([
                            user_signed_in?,
                            Category.cache_key(params[:path]),
                            sort_designers(params[:by]),
                            params[:path],
                            params[:price],
                            params[:price_range],
                            (params[:q] || '_'),
                            (params[:offers] || 'all'),
                            Currency.current,
                            Exclusive.maximum(:updated_at).to_i
                           ].join)
    ].join
  end

  def query_cache_path
    ['shop:query:',
     Digest::MD5.hexdigest([
                            user_signed_in?,
                            Category.cache_key(params[:path]),
                            sort_designers(params[:by]),
                            params[:path],
                            params[:price],
                            (params[:page] || 1),
                            params[:price_range],
                            (params[:q] || '_'),
                            (params[:offers] || 'all'),
                            Currency.current,
                            Exclusive.maximum(:updated_at).to_i
                           ].join)
    ].join
  end

  def exclusive_show_template(exclusive)
    if exclusive.gift_card?
      [exclusive.gift_card_kind, 'gift_card'].join('_')
    else
      'show'
    end
  end
end
