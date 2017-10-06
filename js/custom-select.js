var SelectImpu;

SelectImpu = class SelectImpu {
  constructor(sl, options = {}) {
    this.sl = sl;
    ({cls: this.cls = "select", selCls: this.selCls = "styled-select", optCls: this.optCls = "styled-options", targetAct: this.targetAct} = options);
    if (this.sl) {
      this.sl = $(this.sl);
    }
    if (this.sl.length) {
      this.init();
    }
  }

  init() {
    var SI;
    SI = this;
    return this.sl.each(function() {
      var $listItems, $styledSelect, $t, _o, _preSel, _t, i, j, numberOfOptions, ref;
      $t = $(this);
      numberOfOptions = typeof $t.children === "function" ? $t.children("option").length : void 0;
      $t.addClass("uk-hidden");
      $t.wrap(`<div class=${SI.cls}></div>`);
      $t.after(`<div class=${SI.selCls}></div>`);
      $styledSelect = $t.next(`div.${SI.selCls}`);
      // _t = $t.children? "option"
      //   .eq 0
      //   .text()
      _t = typeof $t.children === "function" ? $t.children("option") : void 0;
      _preSel = _t.filter("[selected]");
      _t = _preSel ? _preSel : _t.eq(0);
      $styledSelect.text(_t.text());
      SI.$list = $("<ul />", {
        class: SI.optCls
      }).insertAfter($styledSelect);
      for (i = j = 0, ref = numberOfOptions - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        _o = typeof $t.children === "function" ? $t.children("option").eq(i) : void 0;
        $("<li />", {
          text: typeof _o.text === "function" ? _o.text() : void 0,
          rel: typeof _o.val === "function" ? _o.val() : void 0
        }).appendTo(SI.$list);
      }
      $listItems = SI.$list.children("li");
      return SI.attEvents($t, $styledSelect, $listItems);
    });
  }

  attEvents($t, $styledSelect, $listItems) {
    var SI;
    // @$targetAct = if @targetAct then $ @targetAct else $styledSelect
    SI = this;
    $styledSelect.on("click", function(e) {
      e.stopPropagation();
      $(`div.${this.selCls}.active`).each(function() {
        return $(this).removeClass("active").next(`ul.${this.optCls}`).hide();
      });
      $(this).toggleClass("active");
      // .next "ul.#{@optCls}"
      // .toggle()
      return SI.$list.show();
    });
    $listItems.on("click", function(e) {
      var _jt;
      e.stopPropagation();
      _jt = $(this);
      $styledSelect.text(_jt.text()).removeClass("active");
      $t.val(_jt.attr("rel"));
      $t.trigger(new $.Event("change"), {}, $t);
      return SI.$list.hide();
    });
    $t.on("change", function(e) {
      if ($t.val().length === 0) {
        return $styledSelect.text("");
      }
    });
    return $(document).on("click", function() {
      // console.log @$targetAct, @$list
      $styledSelect.removeClass("active");
      return SI.$list.hide();
    });
  }

};