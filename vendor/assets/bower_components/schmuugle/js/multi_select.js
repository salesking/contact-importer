/**
 * Replace checkboxes with nicer images
 * Hides the real checkbox and wraps it with font awesome icon markup.
 * Creates a new class for each given item, so it might be slow for 1000 checkboxes in a list
 * == Usage:
 *  $('tbody .check-column :checkbox').multi_select();
 */


!function ($) {
  'use strict';

  // PUBLIC CLASS DEFINITION
  // ==============================
  var MultiSelect = function (element, options) {
    this.options =
    this.$parent =
    this.$element = null;
    this.init( element, options);
  };

  MultiSelect.DEFAULTS = {
    class_base: 'img-checkbox'
//  , template: '<i></i>'
  };

  MultiSelect.prototype.init = function ( element, options) {
    this.$element = $(element);
    this.options = $.extend({}, MultiSelect.DEFAULTS, options);
    this.$element.hide();
    this.$element.wrap( this.options.template );
    // remember parent
    this.$parent = $(this.$element.parent()[0]);
    this.$parent.addClass(this.options.class_base)
                .addClass(this.$element.is(':checked') ? this.options.class_checked : this.options.class_unchecked);
    // listen for clicks
    this.$parent.on('click.multi_select', $.proxy(this.toggle, this));
  };

  MultiSelect.prototype.toggle = function () {
    if (this.$element.is(':checked')) {
      this.$parent.removeClass(this.options.class_checked)
                  .addClass(this.options.class_unchecked);
    }else{
      this.$parent.removeClass(this.options.class_unchecked)
                  .addClass(this.options.class_checked);
    }
    this.$element.prop('checked', !this.$element.is(':checked')).trigger('change');
  };


  // PLUGIN DEFINITION
  // ========================

  var old = $.fn.multi_select;

  $.fn.multi_select = function (option) {

    // opts
    var listen_on = '.table';
//    var listener_event = 'click';
    var listener_event = 'img_checkbox_click';
    var checkbox_sel = '.check-column :checkbox';
    var checkbox_wrapper = 'tbody .check-column'; //:check-column
//
    // checkbox wrapper
    // check_callback

    var lastClicked = false, first, last, checked;

    $(listen_on).on( listener_event, checkbox_sel, function(e, orig_event) {
//      console.log(e);
      // prefer orig_event from custom triggers
      var event = orig_event || e;
      if ( undefined == event.shiftKey ) { return true; }
      if ( event.shiftKey ) {
        if ( !lastClicked ) { return true; }
//        var checks = $( lastClicked ).closest( 'tbody' ).find('.check-column :checkbox'); //
        var checkboxes = $( lastClicked ).closest( 'tbody' ).find(checkbox_sel); //
        first = checkboxes.index( lastClicked );
        last = checkboxes.index( this );
        checked = $(':checkbox', this).prop('checked');
        if ( -1 < first && -1 < last && first != last ) {
          //switch first/last when selected upside down
          if(first > last){
            var old_first = first;
            first = last;
            last = old_first;
          }
          if(listener_event=='img_checkbox_click'){
            // for img checkboxes we just check boxes
//            checkboxes.slice( first,last).prop('checked','checked');
            var boxes =checkboxes.slice( first,last);
            $.each(boxes, function(){
              $(this).data('sm.img_checkbox').check();
            });
          }else{
          // for normal checkboxes this is ok
            checkboxes.slice( first,last).prop( 'checked', 'checked').trigger('click');
          }
      }
      }
      lastClicked = this;
      return true;
    });

    // checkbox in table head toggles all body checkboxes
    $(document).on( 'click', 'thead .check-column :checkbox', function(e) {
      var c = $(this).prop('checked'),
        kbtoggle = 'undefined' == typeof toggleWithKeyboard ? false : toggleWithKeyboard,
        toggle = e.shiftKey || kbtoggle;

      $(this).closest( 'table' ).find('tbody .check-column :checkbox').prop('checked', function() {
        if ( toggle )
          return 'checked' ;
        else if (c)
          return true;
        return false;
      });
    });

//    return this.each(function () {
//      var $this   = $(this),
//          data    = $this.data('sm.multi_select'),
//          options = typeof option == 'object' && option;
//
//      if (!data) $this.data('sm.multi_select', (data = new MultiSelect(this, options)));
//
//    });
  };

  $.fn.multi_select.Constructor = MultiSelect;

  // NO CONFLICT
  // ==================

  $.fn.multi_select.noConflict = function () {
    $.fn.multi_select = old;
    return this;
  };

}(window.jQuery);

