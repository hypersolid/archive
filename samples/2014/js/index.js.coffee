unless shop_page_index
  $ ->
    if $("#shop_page").length
      config =
        per_page: 12

      # Defines vars & cache jquery selectors
      items_root = $(".auctions")
      pageless_root = $(".pageless")
      ajax_status = $("#ajax-status")
      order_high = $("#filters-order .filter[data-order=\"high\"]").first()
      order_low = $("#filters-order .filter[data-order=\"low\"]").first()
      filters_designer = $("#filters-designer .filter")
      filters_order = $("#filters-order .filter")
      loader_template = $("#loader-template").html()
      shop_path = $('#shop_path').text()

      # Sync ajax requests
      $.xhrPool = []
      $.xhrPool.abortAll = ->
        $(this).each (idx, jqXHR) ->
          jqXHR.abort()
        $.xhrPool.length = 0
      $.ajaxSetup
        beforeSend: (jqXHR) ->
          $.xhrPool.push jqXHR
        complete: (jqXHR) ->
          offerToolTip()
          index = $.xhrPool.indexOf(jqXHR)
          $.xhrPool.splice index, 1  if index > -1

      # Caching loaded pages with sessionStorage
      session_storage_key = ->
        return location.protocol+'//'+location.host+location.pathname

      push_pageless = ->
        partial = items_root.clone()
        partial.find('#pageless-loader').remove()
        sessionStorage['ShopCache::' + session_storage_key()] = partial.html()
      pop_pageless = ->
        if sessionStorage['ShopCache::' + session_storage_key()]
          items_root.html(sessionStorage['ShopCache::' + session_storage_key()])

      pop_pageless()

      # Preserving scroll position
      $(document).unload ->
        sessionStorage['ScrollPosition::' + session_storage_key()] = $(document).scrollTop()
      restore_scroll_position = ->
        $(document).scrollTop sessionStorage['ScrollPosition::' + session_storage_key()]

      restore_scroll_position()

      # Binding dynamic event handlers
      $('a.clear-all-filters').on "click", (event) ->
        root = $("a.category.active[data-root='false']").parents(".root-category:first").find('a[data-root="true"]')
        if root
          $(root).addClass('active')
        $("a.category.active[data-root='false']").removeClass('active');
        $("a.active", '.filters-designers').removeClass('active');
        $("a", '#filters-member-offers').removeClass('active');
        $('.search-query').remove()
        $('input', '.prices').val('')
        $('.not-display').removeClass('not-display');
        query()
        event.preventDefault()

      $('.filters-member-offers').on "click", 'a.clear-filters', (event) ->
        $("a", '#filters-member-offers').removeClass('active');
        query()
        event.preventDefault()

      $('.filters-designers').on "click", 'a.clear-filters', (event) ->
        $("a", '#filters-designer').removeClass('active');
        query()
        event.preventDefault()

      $('.filters-category').on "click", 'a.clear-filters', (event) ->
        root = $("a.category.active[data-root='false']").parents(".root-category:first").find('a[data-root="true"]')
        if root
          $(root).addClass('active')
        $("a.category.active[data-root='false']").removeClass('active');
        query()
        event.preventDefault()

      $('a.clear-price-filters').on "click", (event) ->
        event.preventDefault()
        $('input', '.prices').val('')
        query()

      $(".go").on "click", 'a', (event)->
        query()
        event.preventDefault()

      # Filters
      update_filter_dashboard = ->
        $('#filter-dashboard li').hide()
        # categories
        category = $("a.category.active[data-root='false']")
        if category.length
          $('#filter-dashboard-categories span').html category.html()
          $('#filter-dashboard-categories').show()
        # designers
        designers = $("#filters-designer a.active").map ->
          return $(this).html()
        if designers.length
          $('#filter-dashboard-designers span').html designers.toArray().join(', ')
          $('#filter-dashboard-designers').show()
        # offers
        offers = $('#filters-offers a.active')
        if offers.length && offers.first().data('id') != 'all'
          $('#filter-dashboard-offers span').html offers.first().data('name')
          $('#filter-dashboard-offers').show()
        # prices
        price_min = parseFloat($('#price_min').val()) 
        price_max = parseFloat($('#price_max').val())
        if price_min || price_max 
          text = 'More than &pound;' + price_min if price_min 
          text = 'Less than &pound;' + price_max if price_max
          text = 'From &pound;'  + price_min + ' to &pound;' + price_max if price_min && price_max
          $('#filter-dashboard-prices span').html text
          $('#filter-dashboard-prices').show()
  
      clear_filters = {}
      clear_filters['categories'] = -> 
        root = $("a.category.active[data-root='false']").parents(".root-category:first").find('a[data-root="true"]')
        $(root).addClass('active') if root
        $("a.category.active[data-root='false']").removeClass('active')
      clear_filters['designers'] = ->
        $("a", '#filters-designer').removeClass('active')
      clear_filters['offers'] = ->
        $("a", '#filters-offers').removeClass('active')
      clear_filters['prices'] = ->
        $('input', '.prices').val('')
  
      $.each ['offers', 'categories', 'prices', 'designers'], (index, value) ->
        $('#filter-dashboard-' + value + ' a').click (e) ->
          clear_filters[value]()
          e.preventDefault()
          query()
        $('.filters-' + value).on "click", 'a.clear-filters', (event) ->
          clear_filters[value]()
          event.preventDefault()
          query()
  
      $('a.clear-all-filters').on "click", (event) ->
        for key of clear_filters
          clear_filters[key]()
        $('.search-query').remove()
        $('.not-display').removeClass('not-display')
        event.preventDefault()
        query()

      # Resumes shop state after Back and Forward browser actions & also when user views page with hash
      resume = ->
        ajax_status.data('resumed', true)

        params = extract_params_from_hash()

        $(".pageless").empty()

        order_low.removeClass "active"
        order_high.removeClass "active"
        order_high.addClass "active"  if params['price'] is "high"
        order_low.addClass "active"  if params['price'] is "low"

        filters_designer.removeClass "active"
        designers = params['by'].split('_')
        for n of designers
          $("#filters-designer .filter[data-name=\"" + designers[n] + "\"]").addClass "active"

        unless params['path'] is 'main-page'
          link = $("#filters-categories .category[data-path='" + params['path'] + "']")
          link.data "retain-order", true
          link.removeClass "active"
          link.click()
          link.parent().parent().show() unless link.is(":visible")
        else
          shop_index_state()

      # Emulates shop root
      shop_index_state = ->
        $("#switch-category").html "category"
        $("#filters-categories .category-container").hide()
        $(".root-category").removeClass("hidden").show()
        filters_designer.show()
        $(".category").removeClass "active"
        $("#boutique-home").hide()
        query()
      shop_root_category_state = (c) ->
        $("#switch-category").html c.children("a").html()
        $(".root-category").addClass("hidden").hide()
        c.children(".category-container").show()
        c.show()
        $("#boutique-home").show()

      # Resumes pageless after the load of new page
      init_pageless = (params) ->
        try
          $.pagelessReset container: $(".pageless")
        current_page = Math.ceil($('.auction').length / config.per_page)
        total_pages = Math.ceil(($('.exclusives_count').last().text() / config.per_page))
        $(".pageless").pageless
          currentPage: current_page
          totalPages: total_pages
          url: "/shop/exclusives/query?" + $.param(params)
          loaderMsg: "Loading more results"
          loaderImage: "/assets/load.gif"
          complete: push_pageless

      price_range = ->
        @max = parseFloat($('input', '.prices .max').val())
        @min = parseFloat($('input', '.prices .min').val())
        @_prices = {}
        @_prices['max'] = @max unless isNaN(@max)
        @_prices['min'] = @min unless isNaN(@min)

        @_prices

      # Extracts the params for query from the page
      extract_params = ->
        path = $($("#filters-categories .category.active")[0]).data("path") || ""
        designers = $.map($("#filters-designer .filter.active:visible"), (val, i) ->
          $(val).data "name"
        )
        price = "newest"
        price = "high"  if order_high.hasClass("active")
        price = "low"  if order_low.hasClass("active")
        _params = {
          path: path || "main-page",
          by: designers.join("_") || "all-designers",
          price: price,
          price_range: price_range(),
          offers: $('a.active', '#filters-offers').data('id')
        }
        if !!$('#query').val()
          _params['q'] = $('#query').val()

        _params

      # Extracts the params from hash
      extract_params_from_hash = ->
        # params = shop_path
        if History.getState().data.state
          params = History.getState().data.state.replace('/shop/', '')
        else
          params = shop_path
        params = window.location.hash if window.location.hash
        params = params.split('/')
        path = params[0].replace('#', '')
        if path == ''
          path = 'main-page'

        {
          path: path,
          by: params[1],
          price: params[2]
        }

      build_uri = (params) ->
        url = ["/shop"]
        if params['path']
          url.push(params['path'])
        if params['by']
          url.push(params['by'])
        if params['price']
          url.push(params['price'])
        if params['offers']
          url.push(params['offers'])

        url = url.join('/')
        url

      # Makes the ajax query
      query = ->
        params = extract_params()
        $.pagelessReset container: pageless_root
        pageless_root.html loader_template
        $.xhrPool.abortAll()
        ajax_status.removeClass "complete"
        $.ajax
          url: "/shop/exclusives/query?" + $.param(params)
          dataType: 'json'
          success: (data) ->
            items_root.html(data['results'])
            build_designer_filters(data['designers'], data['choose_designers'])
            init_pageless params
            if parseInt($('.exclusives_count').text()) == 0
              $(".not_found", ".filters-prices").show()
            else
              $(".not_found", ".filters-prices").hide()

            unless ajax_status.data('resumed')
              ajax_status.data('suspended', true)
              saveToHistory(build_uri(params))
              breadcrumbs()
            else
              ajax_status.data('resumed', false)

            update_filter_dashboard()

          ajax_status.addClass "complete"

      saveToHistory = (url)->
        History.pushState({ state: url }, window.document.title,  url);

      build_designer_filters = (designers, choosen) ->
        designer_links = []
        choosen_ids = $.map(choosen, (item, _) -> item['id'])
        $.each designers, (_, item) ->
          link_class = ['filter']
          if jQuery.inArray( item['id'], choosen_ids ) != -1
            link_class.push('active')
          designer_links.push('<li><a href="'+item['link']+'" class="'+link_class.join(' ')+'" data-id="'+item['id']+'" data-name="'+item['slug']+'">'+item['name']+'</a></li>')
        $('ul', '#filters-designer').html(designer_links.join(''))

      breadcrumbs = ->
        @container = $('.breadcrumbs')
        @root_category = $(".root-category:visible a:first")
        @categories = [ @root_category ]

        if ($("a.category.active:visible") && $("a.category.active:visible").length > 0)
          @_categories = []
          $.each $("a.category.active:visible").parents("li:not(.root-category)").find('a:first.category'), (_, item) =>
            @_categories.push(item)
          @categories = @categories.concat(@_categories.reverse())

        $('ul li:not(:first-child)', @container).remove()

        $.each @categories, ( _, item) =>
          @link = $("<a />", {
            href: $(item).prop('href'),
            text: $(item).prop('text')
          })
          $('ul', @container).append($("<li/>").append(@link))

      # Page click callbacks
      $("#shop").click (e) ->
        $this = $(this)
        if $this.hasClass("currentpage")
          shop_index_state()
          e.preventDefault()

      $("#boutique-home").click (e) ->
        $("#shop").click()
        e.preventDefault()

      $(".root-category").click (e) ->
        shop_root_category_state $(this)
        e.preventDefault()

      $(".category").click (e) ->
        category = $(this)
        return  if category.hasClass("active")
        unless category.data("retain-order")
          filters_order.removeClass "active"
        else
          category.data "retain-order", false
        category.parent().parent().find(".category-container").hide()
        category.siblings(".category-container").show()
        $(".category").removeClass "active"
        category.addClass "active"
        category_id = parseInt(category.data("id"))

        query()
        e.preventDefault()

      $("#filters-designer").on "click", "a", (e) ->
        $(this).toggleClass "active"
        query()
        e.preventDefault()

      $("#filters-offers").on "click", "a", (e) ->
        $('a',"#filters-offers").removeClass('active')
        $(@).toggleClass "active"
        query()
        e.preventDefault()

      filters_order.click (e) ->
        unless $(this).hasClass("active")
          filters_order.removeClass "active"
          $(this).addClass "active"
        else
          $(this).removeClass "active"
        query()
        e.preventDefault()

      $("#switch-category").click (e) ->
        $("#filters-categories").toggle()
        $(this).toggleClass "opened"

      $("#switch-designer").click (e) ->
        $("#filters-designer").toggle()
        $(this).toggleClass "opened"

      # Actions after page load
      update_filter_dashboard()
      init_pageless extract_params()
      ajax_status.data('suspended', false)
      $(window).bind "hashchange, statechange", (e) ->
        if ajax_status.data('suspended')
          ajax_status.data('suspended', false)
        else
          resume()

shop_page_index = true
