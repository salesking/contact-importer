/*!
 * Schmuugle v0.0.1 
 */
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
    // listen for clicks,
    // todo need to pass orig click event to toggle method so we can fire click on real checkbox
    // prevent click event capture on real checkbox
    this.$parent.on('click.img_checkbox', $.proxy(this.toggle, this) );
    var img_chbx = this;
    this.$parent.on('click.img_checkbox', function(e, img_chbx){
      console.log(e.target);
      $.proxy(img_chbx.toggle, img_chbx);
    } );
    // listen for changes
//    this.$element.on('change', $.proxy(this.toggle, this));
  };

  ImgCheckbox.prototype.toggle = function (orig_e) {
    if (this.$element.is(':checked')) {
      this.$parent.removeClass(this.options.class_checked)
                  .addClass(this.options.class_unchecked);
    }else{
      this.$parent.removeClass(this.options.class_unchecked)
                  .addClass(this.options.class_checked);
    }
    //trigger event with orig value
//    var e = jQuery.Event( "click", orig_e);
    this.$element.prop('checked', !this.$element.is(':checked'));
    // bcs toggle listens to parent click currently gets called twice
    this.$element.trigger('click', orig_e);
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

