text_phone_valid = "Введите правильный номер"
text_cyrillic = "Допустимо: кириллица и дефис"
contact_info = "Заполните контактную информацию"
required_field = "Обязательное поле"
digits_only = "Введите целое число"
text_date_only = "Введите дату рождения в формате ДД.ММ.ГГГГ"
inn_lenght = "ИНН должен состоять из 10 символов."

# window["changeCls"] = (e) ->
#   console.log e
#   $ "#credit-cards, #form-request"
#     .each ->
#       _i = $ @
#       console.log @id, e.attr "id", @id is e.attr "id"
#       _i.addClass "uk-hidden" if _i.hasClass "uk-hidden" is false
#       _i.removeClass "uk-hidden" if @id is e.attr "id"
#   return false

$ ->
  $.validator.addMethod "phone_valid", (a, b) ->
    !!/^[+]\d{2}\s[(]\d{3}[)]\s\d{3}[\-]\d{2}[\-]\d{2}$/gi.test(a)
  , text_phone_valid
  $.validator.addMethod "cyrillic", (a, b) ->
    !/[^а-яёіїґє-\s]/gi.test(a)
  , text_cyrillic
  $.validator.addMethod "date_only", (a, b) ->
    !!/^\d{2}.\d{2}.\d{4}$/gi.test(a)
  , text_date_only
  inp = $ "form input.inp, form select.inp"
  inp.each ->
    _i = $ @
    _i.parents ".input-holder"
      .addClass "filled-input" if _i.val()
    cyrillic_mask = new Inputmask "U{1,64}[ ][U{1,64}]", placeholder: "", showMaskOnHover: off, greedy: off
    switch @.name
      when "lastName"
        cyrillic_mask.mask @
      when "firstName"
        cyrillic_mask.mask @
      when "phone"
        _i.inputmask
          mask: "+38 \\(099\\) 999-99-99"
          greedy: off
          showMaskOnHover: off
      when "email"
        _i.inputmask
          alias: "email"
          greedy: off
          showMaskOnHover: off
      when "city"
        cyrillic_mask.mask @
        # _i.inputmask
        #   mask: "U{1,64}|(U{1,64} U{1,64})"
        #   greedy: off
        #   showMaskOnHover: off
      when "birthDate"
        minDate = new Date()
        maxDate = new Date()
        maxDate.setFullYear maxDate.getFullYear() - 18
        minDate.setFullYear minDate.getFullYear() - 90
        param =
          pos: "bottom"
          format: "DD.MM.YYYY"
          i18n:
            months: ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь']
            weekdays: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
          minDate: UIkit.Utils.moment(minDate).format "DD.MM.YYYY"
          maxDate: UIkit.Utils.moment(maxDate).format "DD.MM.YYYY"
        UIkit.datepicker _i, param
      when "inn"
        _i.inputmask
          mask: "9999999999"
          greedy: off
          showMaskOnHover: off
      else
        ""

  _allSel = $ "select"
  new SelectImpu _allSel, targetAct: ".uk-button.uk-form-select" if UIkit.support.touch is false

  inp.on "blur, change", ->
    _i = $ @
    _if = _i.parents "form"
    _ih = _i.parents ".input-holder"
    if _i.val() then _ih.addClass "filled-input" else _ih.removeClass "filled-input"
    _i.valid()


  _eModal = UIkit.modal "#error-modal", center: on
  _cModal = UIkit.modal "#complete-modal", center: on

  $ "form"
    .validate
      rules:
        firstName:
          required: on
          cyrillic: on
        lastName:
          required: on
          cyrillic: on
        inn:
          digits: on
          rangelength: [10, 10]
        city: required: on
        email: required: on
        birthDate:
          date_only: on
          required: on
        employment: required: on
        agree_personal: required: on
        phone:
          required: on
          phone_valid: on
      messages:
        firstName: required: required_field
        lastName: required: required_field
        inn:
          digits: digits_only
          rangelength: inn_lenght
        city: required: required_field
        phone: required: required_field
        email: required: required_field
        birthDate: required: required_field
        employment: required: required_field
        agree_personal: required: required_field
      errorClass: "error"
      validClass: "valid"
      errorElement: "span"
      submitHandler: (evt) ->
        _data =
          birthDate : evt.elements.birthDate.value
          identCode : evt.elements.inn.value or evt.elements.birthDate.value
          phone     : "+380#{evt.elements.phone.inputmask.unmaskedvalue()}"
          firstName : evt.elements.firstName.value
          lastName  : evt.elements.lastName.value
          employment: evt.elements.employment.value
          offerCode : evt.elements.offerCode.value
          city      : evt.elements.city.value
          email     : evt.elements.email.value
          partner   : 141
        data = $.param _data
        $.ajax
          url: "http://partner.finline.ua/api/applyWeb/v2/"
          type: "POST"
          dataType: "json"
          data: data
          beforeSend: ->
            $ ".uk-overlay-icon-spinner"
              .toggle()
          success: (d) ->
            console.log "success", d
            if d.error
              _eModal.find "p"
                .text d.error
              _eModal.show()
            else
              _cModal.show()
            evt.reset()
            $ evt
              .validate()
              .resetForm?()
            inp.each ->
              _i = $ @
              _i.trigger $.Event("change"), {}, _i if @name is "employment"
              _i.parents ".input-holder"
                .removeClass "filled-input"
            $ ".uk-overlay-icon-spinner"
              .toggle()

          error: (d) ->
            console.log d
            _eModal.show()

        return false
