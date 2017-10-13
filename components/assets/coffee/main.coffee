
text_phone_valid = "Введите правильный номер"
text_cyrillic = "Допустимо: кириллица и дефис"
contact_info = "Заполните контактную информацию"
required_field = "Обязательное поле"
digits_only = "Введите целое число"
text_date_only = "Введите дату рождения в формате ДД.ММ.ГГГГ"
inn_lenght = "ИНН должен состоять из 10 символов."
inn_date_only = "Введите правильный ИНН."


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
  $.validator.addMethod "inn_valid", (a, b) ->
    _bd = $ "input[name=\"birthDate\"]"
      .val().split "."
    _bd = new Date _bd[2] + "-" + _bd[1] + "-" + _bd[0]
    _innd = new Date "1900-01-01"
    _innd.setDate _innd.getDate() + (Number(a[0...5])-1)
    _bd.getDate() is _innd.getDate()
  , inn_date_only
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
      when "identCode"
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

  remoteID = 0
  _eModal = UIkit.modal "#error-modal", center: on
  _cModal = UIkit.modal "#complete-modal", center: on
  _smsAlertError = (_spinn) ->
    UIkit.modal.alert "<h1 class=\"uk-text-danger\">Вами введен неверный код</h1>", labels: "Ok": "Ok"
    .on
      "hide.uk.modal": -> _spinn.toggle()
  _smsModal = ->
    _spinn = $ "<div>"
      .addClass "uk-overlay-background uk-overlay-icon uk-overlay-icon-spinner uk-overlay-panel uk-position-z-index"
    _pmpt = UIkit.modal.prompt "<h1>Введите код из SMS</h1><p>На ваш мобильный телефон отправлен SMS-пароль из шести цифр</p>", "", (newV) ->
      # newV = new String newV
      # console.log newV, newV.length
      if newV.length and newV.length is 6
        _spinn.toggle()
        _data = 
          id: remoteID
          code: newV
        _data = $.param _data
        $.ajax 
          url: "http://partner.finline.ua/api/verify/"
          type: "POST"
          data: _data
          success: (d) ->
            # console.log d
            if d.sms_status is "serverError"
              _smsAlertError _spinn
            else
              _pmpt.hide()
              _cModal.show()
      return off
    ,
      center: on
      labels: 
        "Ok": "Отправить"
        "Cancel": "Отмена"
    
    _pmpt.find ".uk-modal-dialog > div"
      .append _spinn
    _pmpt.find "input[type=\"text\"]"
      .inputmask
        mask: "999999"
        greedy: off
        showMaskOnHover: off
    # .on
    #   "show.uk.modal": -> console.log "show"
    #   "hide.uk.modal": -> console.log "hide"
  
  $ "form"
    .validate
      rules:
        firstName:
          required: on
          cyrillic: on
        lastName:
          required: on
          cyrillic: on
        identCode:
          required: on
          digits: on
          inn_valid: on
          rangelength: [10, 10]
        city: required: on
        email: required: off
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
        identCode:
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
          identCode : evt.elements.identCode.value
          phone     : "+380#{evt.elements.phone.inputmask.unmaskedvalue()}"
          firstName : evt.elements.firstName.value
          lastName  : evt.elements.lastName.value
          employment: evt.elements.employment.value
          offerCode : evt.elements.offerCode.value
          city      : evt.elements.city.value
          email     : evt.elements.email.value
          verification: "|6"
          partner   : 141
        data = $.param _data
        $.ajax
          # url: "http://partner.finline.ua/api/applyWeb/v2/"
          url: "http://finline.dev/api/apply/"
          # type: "POST"
          type: "GET"
          # dataType: "json"
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
              remoteID = d.remoteID
              _smsModal() if remoteID
              # _cModal.show()
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
