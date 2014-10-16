/**
 * Replace checkboxes with nicer images
 * Hides the real checkbox and wraps it with font awesome icon markup.
 * Creates a new class for each given item, so it might be slow for 1000 checkboxes in a list
 * == Usage:
 *  $('tbody .check-column :checkbox').img_checkbox();
 */


!function ($) {
  'use strict';

  // PUBLIC CLASS DEFINITION
  // ==============================
  var ImgCheckbox = function (element, options) {
    this.options =
    this.$parent =
    this.$element = null;
    this.init( element, options);
  };

  ImgCheckbox.DEFAULTS = {
    class_checked: 'fa-check-square-o'
  , class_unchecked: 'fa-square-o'
  , class_base: 'img-checkbox fa fa-lg'
  , template: '<i></i>'
  };

  ImgCheckbox.prototype.init = function ( element, options) {
    this.$element = $(element);
    this.options = $.extend({}, ImgCheckbox.DEFAULTS, options);
    this.$element.hide();
    this.$element.wrap( this.options.template );
    // remember parent
    this.$parent = $(this.$element.parent()[0]);
    this.$parent.addClass(this.options.class_base)
                .addClass(this.$element.is(':checked') ? this.options.class_checked : this.options.class_unchecked);

    // prevent browser highlight of selections
    this.$element.parent()[0].onselectstart = function(e){ return false; };

    // listen for clicks,
    // todo need to pass orig click event to toggle method so we can fire click on real checkbox
    // prevent click event capture on real checkbox
    this.$parent.on('click.img_checkbox', $.proxy(this.toggle, this) );
//    var img_chbx = this;

//    this.$parent.on('click.img_checkbox', function(e){ //img_chbx
//      console.log(e.target);
//      if(e.target != this) return;
//      var img_checkbox = $(':checkbox', e.target).data('sm.img_checkbox');
//      img_checkbox.toggle();
//      TODO trigger click
//      only handle direct div wrapper clicks, not bubbled up ones from real checbox
//      $.proxy(img_chbx.toggle, img_chbx);
//      img_checkbox.$element.trigger('click', e); //'click'
//    } );

    // listen for changes
//    this.$element.on('change', $.proxy(this.toggle, this));
  };

  ImgCheckbox.prototype.toggle = function (e) {
    // return if event target is NOT this parent, so method does not get called twice
    if(this.$parent[0] != e.target){ return false;}
    if (this.$element.is(':checked')) {
      this.$parent.removeClass(this.options.class_checked)
                  .addClass(this.options.class_unchecked);
      this.$element.prop('checked', !this.$element.is(':checked'));
    }else{
      this.check();
//      this.$parent.removeClass(this.options.class_unchecked)
//                  .addClass(this.options.class_checked);
    }
    // custom click event bcs jQuery triggers the real click for checkboxes without this event. so we cannot
    // capture shift/alt and other event details. And real click would fire this method twice bcs toggle listens to
    // parent click
    // listing method must define callback with two args bcs jquery always creates its own event as first arg:
    //  $(listen_on).on( listener_event, checkbox_sel, function(e, orig_event) {
    this.$element.trigger('img_checkbox_click', e); //'click'
//    var e = jQuery.Event( "click", orig_e);
    return false;
  };

  ImgCheckbox.prototype.check = function () {
    this.$parent.removeClass(this.options.class_unchecked).addClass(this.options.class_checked);
    this.$element.prop('checked', 'checked');
  };


  // PLUGIN DEFINITION
  // ========================

  var old = $.fn.img_checkbox;

  $.fn.img_checkbox = function (option) {
    return this.each(function () {
      var $this   = $(this),
          data    = $this.data('sm.img_checkbox'),
          options = typeof option == 'object' && option;

      if (!data) $this.data('sm.img_checkbox', (data = new ImgCheckbox(this, options)));

    });
  };

  $.fn.img_checkbox.Constructor = ImgCheckbox;

  // NO CONFLICT
  // ==================

  $.fn.img_checkbox.noConflict = function () {
    $.fn.img_checkbox = old;
    return this;
  };

}(window.jQuery);

