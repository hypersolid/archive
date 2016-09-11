class ShopsController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_admin!, :only => [:preview]

  attr_reader :shop, :shops, :exclusives
  helper_method :shop, :shops, :exclusives

  caches_action :index, layout: false, cache_path: Proc.new { |c| c.send(:index_cache_path) }
  caches_action :show, layout: false, cache_path: Proc.new { |c| c.send(:show_cache_path) }

  def index
    @shops = Shop.current.includes(:image).all
    @shops.sort!{|a,b| a.get_priority(current_domain) <=> b.get_priority(current_domain)}
    @meta_source = MetaData.by_label('popups')
  end

  def show
    @shop = @meta_source = Shop.with_deleted.find(params[:id])

    # routing for obsolete shops
    if @shop.closed? || @shop.ended? || @shop.deleted?
      path = @shop.designer ? designer_path(@shop.designer) : root_path
      redirect_to path and return
    end

    # routing for not started shops
    if !@shop.started?
      path = admin_signed_in? ? preview_shop_path(@shop) : root_path
      redirect_to path and return
    end

    @exclusives = @shop.current_exclusives
  end

  def preview
    @shop = Shop.find(params[:id])
    @exclusives = @shop.current_exclusives
    render :show
  end

  private

  def index_cache_path
    "popups:index:#{current_domain}:#{Shop.cache_key}"
  end

  def show_cache_path
    shop = Shop.find(params[:id])

    ['popups', 'show',
     shop.cache_key, shop.started?, user_signed_in?,
     Currency.current ].join(':')
  end

end
