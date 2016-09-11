$ ->
  if $('#home-search-form').length
    # Backbone models
    Make = Backbone.Model.extend()
    Model = Backbone.Model.extend()
    Spec = Backbone.Model.extend()

    # Backbone collections
    Makes = Backbone.Collection.extend(model: Make)
    Models = Backbone.Collection.extend(model: Model)
    Specs = Backbone.Collection.extend(model: Spec)
    
    # Backbone views
    ChainedSelectView = Backbone.View.extend(
      initialize: (options) ->
        _.bindAll @, "addOne", "addAll", "resetDependent"
        @dependent_view = options.dependent_view
        @dependent_url = options.dependent_url
      events:
        change: 'updateDependent'
      addOne: (model) ->
        $(@el).append new OptionView(model: model).render().el
        return
      addAll: ->
        @.$el.html('')
        @collection.each @addOne
        return
      resetDependent: ->
        return unless @dependent_view
        @dependent_view.$el.html('')
        @dependent_view.collection.reset()
        @dependent_view.resetDependent()
      updateDependent: ->
        return unless @dependent_view
        @resetDependent()

        return unless @.$el.val() != ''

        @dependent_view.$el.append('<option value="">' + $.t('messages.loading') + '</option>')
        
        @dependent_view.collection.url = @dependent_url(@.$el.val())

        $this = @
        @dependent_view.collection.fetch
          success: ->
            view = $this.dependent_view 
            view.addAll()
            if view.collection.length == 0
              view.$el.prepend('<option value="">' + $.t('messages.nothing_found') + '</option>')
            else if view.collection.length == 1
              $this.dependent_view.updateDependent()
            else
              view.$el.prepend('<option value="">' + $.t('messages.select', subject: $.t('validation.fields.' + view.$el.attr('name'))) + '</option>')
              view.$el.val ''
    )
    OptionView = Backbone.View.extend(
      tagName: "option"
      initialize: (options) ->
        @model = options.model
      render: ->
        @.$el.attr("value", @model.get("id")).html @model.get("name")
        @
    )

    # Backbone logic
    specsView = new ChainedSelectView(
      el: $("#spec")
      collection: new Specs()
    )
    modelsView = new ChainedSelectView(
      el: $("#model")
      collection: new Models()
      dependent_view: specsView
      dependent_url: (id)->
        '/vehicle/models/' + id + '/specs?year_id=' + $('#year').val() + '&make_id=' + $('#make').val()
    )
    makesView = new ChainedSelectView(
      el: $("#make")
      collection: new Makes()
      dependent_view: modelsView
      dependent_url: (id)->
        '/vehicle/makes/' + id + '/models?year_id=' + $('#year').val()
    )
    yearsView = new ChainedSelectView(
      el: $("#year")
      dependent_view: makesView
      dependent_url: (id)->
        '/vehicle/years/' + id + '/makes'
    )

    # Other initializations
    i18n.init
      lng: 'ru'
      fallbackLng: false
      resStore: window.resources
    
    $("#tabs").tabs()
    
    for field in ['year', 'make', 'model', 'spec']
      jQuery.validator.addMethod field + "_required", ((value) ->
        parseInt(value) > 0
      ), $.t('validation.errors.select_required', fieldname:
          $.t('validation.fields.' + field)
      )

    $("#search-model-form form").validate
      onkeyup: false
      onclick: false
      onfocusin: false
      onfocusout: false
      rules:
        year: 'year_required'
        make: 'make_required'
        model: 'model_required'
        spec: 'spec_required'


    jQuery.validator.addMethod 'vin_format', ((value) ->
      value.trim().length == 17
    ), $.t('validation.errors.wrong_format', fieldname:
        $.t('validation.fields.vin')
    )
    $("#search-vin-form form").validate
      onkeyup: false
      onclick: false
      onfocusin: false
      onfocusout: false
      rules:
        vin_code: 'vin_format'

    $('#year option[value=""]').text($.t('messages.select', subject: $.t('validation.fields.year')))
    $('#year').val('')
    
    $('#vin_code').keyup ->
      $this = $(this)
      message = $this.siblings('span')
      
      if $this.val().trim().length == 17
        $.ajax
          dataType: "json",
          url: '/vehicle/vehicles/vin_lookup',
          data: {vin: $this.val()},
          success: (data)->
            if data['year']
              message.text data['year'] + ' ' + data['make'] + ' ' + data['model']
            else
              message.text $.t('validation.errors.not_found', fieldname: $.t('validation.fields.vin'))
    $('#vin_code').keyup()
