/**
 * Used in example edit views
 */

$( document ).ready(function() {
  $('#cash_discount').hide();
  $('#currency').hide();
  $('#advanced_fields').hide();
  // toggle active state of side links
  $("button[data-name='cash_discount']").click(function(el){
    $('#cash_discount').toggle();
  });
  $("button[data-name='currency']").click(function(el){
    $('#currency').toggle();
  });
  $("button[data-name='advanced_fields']").click(function(el){
    $('#advanced_fields').toggle();
  });


});
