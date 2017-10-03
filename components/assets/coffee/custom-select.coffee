class SelectImpu
  constructor: (@sl, options = {}) ->
    {@cls = "select", @selCls = "styled-select", @optCls = "styled-options", @targetAct} = options

    @sl = $ @sl if @sl
    @init() if @sl.length

  init: ->
    SI = @
    @sl.each ->
      $t = $ @
      numberOfOptions = $t.children? "option"
        .length

      $t.addClass "uk-hidden"
      $t.wrap "<div class=#{SI.cls}></div>"
      $t.after "<div class=#{SI.selCls}></div>"

      $styledSelect = $t.next "div.#{SI.selCls}"
      # _t = $t.children? "option"
      #   .eq 0
      #   .text()
      _t = $t.children? "option"
      _preSel = _t.filter "[selected]"
      _t = if _preSel then _preSel else _t.eq 0
      $styledSelect.text _t.text()

      SI.$list = $ "<ul />", class: SI.optCls
        .insertAfter $styledSelect

      for i in [0..numberOfOptions-1]
        _o = $t.children? "option"
          .eq i
        $ "<li />", text: _o.text?(), rel: _o.val?()
          .appendTo SI.$list

      $listItems = SI.$list.children "li"

      SI.attEvents $t, $styledSelect, $listItems

  attEvents: ($t, $styledSelect, $listItems) ->
    # @$targetAct = if @targetAct then $ @targetAct else $styledSelect
    SI = @
    $styledSelect.on "click", (e) ->
      e.stopPropagation()
      $ "div.#{@selCls}.active"
        .each ->
          $ @
            .removeClass "active"
            .next "ul.#{@optCls}"
            .hide()
      $ @
        .toggleClass "active"
        # .next "ul.#{@optCls}"
        # .toggle()
      SI.$list.show()

    $listItems.on "click", (e) ->
      e.stopPropagation()
      _jt = $ @
      $styledSelect.text _jt.text()
        .removeClass "active"
      $t.val _jt.attr "rel"
      $t.trigger new $.Event("change"), {}, $t
      SI.$list.hide()

    $t.on "change", (e) ->
      $styledSelect.text "" if $t.val().length is 0

    $ document
      .on "click", ->
        # console.log @$targetAct, @$list
        $styledSelect.removeClass "active"
        SI.$list.hide()