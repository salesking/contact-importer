$( document ).ready(function() {

  // toggle active state of side links
  $('.side-list-item').click(function(el){
    $(this).parents('.side-list').children('.side-list-item').removeClass('active');
    $(this).addClass('active');
  });



  // checkbox replacements
  $('tbody .check-column :checkbox').img_checkbox();
  $('.check-column').multi_select();
});
