var contact_info, digits_only, inn_lenght, required_field, text_cyrillic, text_date_only, text_phone_valid;

text_phone_valid = "Введите правильный номер";

text_cyrillic = "Допустимо: кириллица и дефис";

contact_info = "Заполните контактную информацию";

required_field = "Обязательное поле";

digits_only = "Введите целое число";

text_date_only = "Введите дату рождения в формате ДД.ММ.ГГГГ";

inn_lenght = "ИНН должен состоять из 10 символов.";

// window["changeCls"] = (e) ->
//   console.log e
//   $ "#credit-cards, #form-request"
//     .each ->
//       _i = $ @
//       console.log @id, e.attr "id", @id is e.attr "id"
//       _i.addClass "uk-hidden" if _i.hasClass "uk-hidden" is false
//       _i.removeClass "uk-hidden" if @id is e.attr "id"
//   return false
$(function() {
  var _allSel, _cModal, _eModal, inp;
  $.validator.addMethod("phone_valid", function(a, b) {
    return !!/^[+]\d{2}\s[(]\d{3}[)]\s\d{3}[\-]\d{2}[\-]\d{2}$/gi.test(a);
  }, text_phone_valid);
  $.validator.addMethod("cyrillic", function(a, b) {
    return !/[^а-яёіїґє-\s]/gi.test(a);
  }, text_cyrillic);
  $.validator.addMethod("date_only", function(a, b) {
    return !!/^\d{2}.\d{2}.\d{4}$/gi.test(a);
  }, text_date_only);
  inp = $("form input.inp, form select.inp");
  inp.each(function() {
    var _i, cyrillic_mask, maxDate, minDate, param;
    _i = $(this);
    if (_i.val()) {
      _i.parents(".input-holder").addClass("filled-input");
    }
    cyrillic_mask = new Inputmask("U{1,64}[ ][U{1,64}]", {
      placeholder: "",
      showMaskOnHover: false,
      greedy: false
    });
    switch (this.name) {
      case "lastName":
        return cyrillic_mask.mask(this);
      case "firstName":
        return cyrillic_mask.mask(this);
      case "phone":
        return _i.inputmask({
          mask: "+38 \\(099\\) 999-99-99",
          greedy: false,
          showMaskOnHover: false
        });
      case "email":
        return _i.inputmask({
          alias: "email",
          greedy: false,
          showMaskOnHover: false
        });
      case "city":
        return cyrillic_mask.mask(this);
      // _i.inputmask
      //   mask: "U{1,64}|(U{1,64} U{1,64})"
      //   greedy: off
      //   showMaskOnHover: off
      case "birthDate":
        minDate = new Date();
        maxDate = new Date();
        maxDate.setFullYear(maxDate.getFullYear() - 18);
        minDate.setFullYear(minDate.getFullYear() - 90);
        param = {
          pos: "bottom",
          format: "DD.MM.YYYY",
          i18n: {
            months: ['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'],
            weekdays: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
          },
          minDate: UIkit.Utils.moment(minDate).format("DD.MM.YYYY"),
          maxDate: UIkit.Utils.moment(maxDate).format("DD.MM.YYYY")
        };
        return UIkit.datepicker(_i, param);
      case "inn":
        return _i.inputmask({
          mask: "9999999999",
          greedy: false,
          showMaskOnHover: false
        });
      default:
        return "";
    }
  });
  _allSel = $("select");
  if (UIkit.support.touch === false) {
    new SelectImpu(_allSel, {
      targetAct: ".uk-button.uk-form-select"
    });
  }
  inp.on("blur, change", function() {
    var _i, _if, _ih;
    _i = $(this);
    _if = _i.parents("form");
    _ih = _i.parents(".input-holder");
    if (_i.val()) {
      _ih.addClass("filled-input");
    } else {
      _ih.removeClass("filled-input");
    }
    return _i.valid();
  });
  _eModal = UIkit.modal("#error-modal", {
    center: true
  });
  _cModal = UIkit.modal("#complete-modal", {
    center: true
  });
  return $("form").validate({
    rules: {
      firstName: {
        required: true,
        cyrillic: true
      },
      lastName: {
        required: true,
        cyrillic: true
      },
      inn: {
        digits: true,
        rangelength: [10, 10]
      },
      city: {
        required: true
      },
      email: {
        required: true
      },
      birthDate: {
        date_only: true,
        required: true
      },
      employment: {
        required: true
      },
      agree_personal: {
        required: true
      },
      phone: {
        required: true,
        phone_valid: true
      }
    },
    messages: {
      firstName: {
        required: required_field
      },
      lastName: {
        required: required_field
      },
      inn: {
        digits: digits_only,
        rangelength: inn_lenght
      },
      city: {
        required: required_field
      },
      phone: {
        required: required_field
      },
      email: {
        required: required_field
      },
      birthDate: {
        required: required_field
      },
      employment: {
        required: required_field
      },
      agree_personal: {
        required: required_field
      }
    },
    errorClass: "error",
    validClass: "valid",
    errorElement: "span",
    submitHandler: function(evt) {
      var _data, data;
      _data = {
        birthDate: evt.elements.birthDate.value,
        identCode: evt.elements.inn.value || evt.elements.birthDate.value,
        phone: `+380${evt.elements.phone.inputmask.unmaskedvalue()}`,
        firstName: evt.elements.firstName.value,
        lastName: evt.elements.lastName.value,
        employment: evt.elements.employment.value,
        offerCode: evt.elements.offerCode.value,
        city: evt.elements.city.value,
        email: evt.elements.email.value,
        partner: 141
      };
      data = $.param(_data);
      $.ajax({
        url: "http://partner.finline.ua/api/applyWeb/v2/",
        type: "POST",
        dataType: "json",
        data: data,
        beforeSend: function() {
          return $(".uk-overlay-icon-spinner").toggle();
        },
        success: function(d) {
          var base;
          console.log("success", d);
          if (d.error) {
            _eModal.find("p").text(d.error);
            _eModal.show();
          } else {
            _cModal.show();
          }
          evt.reset();
          if (typeof (base = $(evt).validate()).resetForm === "function") {
            base.resetForm();
          }
          inp.each(function() {
            var _i;
            _i = $(this);
            if (this.name === "employment") {
              _i.trigger($.Event("change"), {}, _i);
            }
            return _i.parents(".input-holder").removeClass("filled-input");
          });
          return $(".uk-overlay-icon-spinner").toggle();
        },
        error: function(d) {
          console.log(d);
          return _eModal.show();
        }
      });
      return false;
    }
  });
});