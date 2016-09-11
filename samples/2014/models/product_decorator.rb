Spree::Product.class_eval do
  before_save :update_clean_part_number

  has_and_belongs_to_many :vehicles, class_name: 'Vehicle::Vehicle'

  ### Tecdoc linkage ###
  def tecdoc_linkage(manufacturer_name)
    eligible_articles = Tecdoc::Article.search_tecdoc_article_ids(part_number, manufacturer_name)
    return if eligible_articles.empty?
    image_urls = Tecdoc::Article.image_urls(eligible_articles)
    if image_urls.present?
      self.images.destroy_all
      image_urls.each do |url|
        self.images << Spree::Image.create(attachment: open(url))
      end
    end
    localized_name = Tecdoc::Article.localized_name(eligible_articles)
    self.name = [manufacturer_name,
                 self.part_number,
                 localized_name].join(' ')
    self.save
  end

  ### Aftermarket Catalog Enhanced Standard (ACES) methods ###
  def update_by_aces_data(aces_product)
    self.vehicles << Vehicle::Vehicle.from_aces_product(aces_product)
  end

  ### Search methods ###
  def self.create_by_aces_data(aces_product, shipping_category, manufacturer)
    product = Spree::Product.create({
        name: [manufacturer, aces_product.part].join(' '),
        shipping_category: shipping_category,
        price: aces_product.price,
        note: aces_product.note,
        part_number: aces_product.part,
        manufacturer: manufacturer,
        available_on: Date.current,
        vehicles: [ Vehicle::Vehicle.from_aces_product(aces_product) ]  
      })

    # TODO enable qty update
    # Spree::Variant.handle_region(product, aces_product)
    # Spree::Variant.handle_stock_items(product, aces_product)

    product
  end

  def self.search_by_model(vehicle_ids)
    self
      .joins('INNER JOIN spree_products_vehicle_vehicles ON spree_products.id = spree_products_vehicle_vehicles.product_id')
      .where('spree_products_vehicle_vehicles.vehicle_id IN (?)', [*vehicle_ids])
  end

  def self.search_by_part_number(query)
    sql_where = []
    cleared_query = Spree::Product.clear(query)

    # search for analogs via Tecdoc
    tecdoc_results = Tecdoc::Article.search(query)
    if tecdoc_results.present?
      tecdoc_results = tecdoc_results.map{|row| "('#{clear(row[1])}','#{row[2]}')" }
      sql_where << "(clean_part_number, manufacturer) IN (#{tecdoc_results.join(',')})"
    end

    # search for direct matches
    sql_where << "clean_part_number = '#{cleared_query}'"

    # search for matches based on additional information (ACES)
    sql_where << "note LIKE '% #{cleared_query}'"
    sql_where << "note LIKE '%,#{cleared_query}'"
    sql_where << "note LIKE '#{cleared_query} %'"
    sql_where << "note LIKE '#{cleared_query},%'"
    sql_where << "note LIKE '% #{cleared_query} %'"
    sql_where << "note LIKE '% #{cleared_query},%'"
    sql_where << "note LIKE '%,#{cleared_query} %'"
    sql_where << "note LIKE '%,#{cleared_query},%'"

    where sql_where.join(' OR ')
  end

  def self.clear(number)
    number.gsub(/[^\d\w]/, '').upcase unless number.blank?
  end

  def analogs
    Tecdoc::Article.search(self.part_number, self.manufacturer)
  end
  
  ### Misc ###
  def postprocess
    makes = {}
    
    self.vehicles.each do |vehicle|
      make = vehicle.make.title
      spec = "#{vehicle.model.title} #{vehicle.body.title} #{vehicle.engine.title}"
      year = vehicle.year.number
      makes[make] ||= {}
      makes[make][spec] ||= []
      makes[make][spec].push year.to_i
    end

    html = "" 
    makes.each do |k, v|
      html += "<h5>#{k}</h5>"
      v.each do |spec_k, spec_v|
        years = spec_v.uniq
        if years.count > 2
          html += "#{years.min}-#{years.max}"
        else
          html += years.join(',')
        end  
        html += " #{spec_k}<br />"
      end
    end
    self.description = html
    self.save
  end

  private
  def update_clean_part_number
    self.clean_part_number = Spree::Product.clear(self.part_number)
  end

end
