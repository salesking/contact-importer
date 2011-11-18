$(function() {

  var src_container =  $('#csv_fields'),
      trgt_container = $('#schema_fields ');

  /*
   *  events
   */
  $('.kill').live('click', function(e){revert_field(e, this)});
  
  src_container.delegate('.field:not(.ui-draggable)', 'mouseenter', function() {
    $(this).draggable({revert: 'invalid'});
  });
  
  trgt_container.delegate('.field:not(.ui-droppable)', 'mouseenter', function() {
    $(this ).droppable({
      accept: "#csv_fields li",
      hoverClass: "over",
//      drop: function(event, ui) {drop_field( $(event.target), ui);}
//      event target is now $(this) .. ui will fix it http://bugs.jqueryui.com/ticket/7852
      drop: function(event, ui) {drop_field($(this), ui);}
    });
  });

  /*
   *  create inline js uploader
   */
  var uploader = new qq.FileUploader({
//    debug: true,
    multiple: false,
    /* Do not use the $ selector here */
    element: document.getElementById("file-upload"),
    action: '/imports/upload',
    allowedExtensions: ["txt","csv"],
    sizeLimit: 5048576, //this uploads via browser memory. 5 MB example.
    onSubmit: function(id, fileName) {
      uploader.setParams({
        authenticity_token: $("input[name='authenticity_token']").val(),
        kind: $("#import_kind option:selected").val(),
        col_sep: $("#import_col_sep").val(),
        quote_char: $("#import_quote_char").val()
      });
    },
    onComplete: function(id, fileName, responseJSON){
      insert_fields(responseJSON)
    }
  }); // uploader

  //add mappings as hidden field before form submit
  // should probalby insert those directly when beeing dropped => check mappings index
  $(':submit').click(function(e) {
//    e.preventDefault();
    var data = $('.field.dropped', trgt_container);
    var mappings = [];
    $.each(data, function(i) {
      var el = $(this),
          src_ids = [];
      //collect source ids
      $.each($('.source',el), function(){
        src_ids.push( $(this).attr('data-source') );
      });
      mappings.push("<input type='hidden' name='import[mappings_attributes]["+i+"][source]' value='" + src_ids.join(',') + "'>");
      mappings.push("<input type='hidden' name='import[mappings_attributes]["+i+"][target]' value='" + $('.target',el).attr('data-target')+ "'>");
      //grab converion type
      if($("input[name='conv_type']",el).length > 0){
        mappings.push("<input type='hidden' name='import[mappings_attributes]["+i+"][conv_type]' value='" +$("input[name='conv_type']",el).val()+ "'>");
      }
      //enums
      if( $('.options',el).length > 0 ){
        var els = $('.options :text',el),
            opts = {};
        $.each(els, function(){ opts[$(this).attr('name')] = $(this).val() });
        //save conversion options as json
        mappings.push("<input type='hidden' name='import[mappings_attributes]["+i+"][conv_opts]' value='" +JSON.stringify(opts)+ "'>");
      }
    });
    $('form').append(mappings.join(''));
  });

  /*
   * insert csv and json-schema fields into dom
   */
  function insert_fields(responseJSON) {
//    console.log(responseJSON);
    // create dragable headers + droppabe json-schema list
    var csv = ['<ul>'];
    var schema = ['<ul>'];
    $.each(responseJSON.headers, function(i) {
      csv.push("<li class='field' data-name='" + this + "' data-source='"+i+"'>" +  this + "</li>");
    });
    //schema = [{'first_name'=>{ 'type'=>'string', 'enum'=>[1,2,3] },{} ,..  ]
    $.each(responseJSON.schema, function() {
      var el = this,
          name,
          attrs = [];
      for(var n in el){name = n} //obj only has one key
      attrs.push("data-target='"+name+"'");
      //collect data attribues from json schema properties
      for(var i in el[name]){ attrs.push("data-"+i+"='"+el[name][i]+"'") }
      var html = "<li class='field'><div class='target' "+ attrs.join(' ') + ">" + name + "</div></li>";
      schema.push(html);
    });
    csv.push("</ul>");
    schema.push("</ul>");

    src_container.append(csv.join('') );
    trgt_container.append(schema.join('') );
    $('.field', trgt_container).trigger('mouseenter'); // init dropabble
    // remember attachment_id in hidden input
    $('#import_attachment_id').val(responseJSON.attachment_id);
  }
  
  /*
   * drop event of receiving list
   * @param el jQuery object with the receiving list item
   * @param ui ui-object draggable helper
   */
  function drop_field(el, ui) {
    add_fields(el, ui);
    //add special mapping fields
    if($('.target',el).attr('data-enum') != undefined){ add_enum_fields(el) }
    if($('.target',el).attr('data-format') == 'date'){ add_date_fields(el) }
  }

  /*
   * adds basic markup to a target field
   * @param el jQuery object with the receiving list item
   * @param ui ui-object draggable helper
   */
  function add_fields(el, ui) {
    $('.target',el).after(
              "<div class='source'" +
                "data-name='"+ ui.draggable.attr('data-name') + "' "+
                "data-source='"+ ui.draggable.attr('data-source') + "'>" +
                "<div>" +
                  ui.draggable.text() +
                "</div>" +
                "<div class='map_actions'>" +
                  "<div class='kill'> x </div>" +
                "</div>"+
              "</div>");
    ui.draggable.hide();
    if ( $('.source',el).length > 1 && $("input[name='conv_type']",el).length == 0){ // multiple source fields
      el.append("<input name='conv_type' type='hidden' value='join'>");
    }
    el.addClass('dropped');
  }

  /*
   * adds enum markup to a target field
   * @param el jQuery object with the receiving list item
   */
  function add_enum_fields(el) {
    var opts = $('.target',el).attr('data-enum').split(','),
        els = ["<div class='options'>"];
    $.each(opts, function(){
      var html = "<div> <input class='mini' name='"+this+"' type='text'> <label>=> " + this + "</label></div>";
      els.push(html);
    });
    els.push("<input name='conv_type' type='hidden' value='enum'>");
    els.push("</div>");
    el.append( els.join('') );
  }
  /*
   * adds date markup to a target field
   * @param el jQuery object with the receiving list item
   */
  function add_date_fields(el) {
    var els = ["<div class='options'>"];
    var html = "<div> <input class='mini' name='date' type='text'> <label>=> Target format YYYY.MM.DD</label></div>";
    els.push(html);
    els.push("<div class='help-block'>Use Placeholders %Y %m %d describing the incoming date format.</div>");
    els.push("</div>");
    els.push("<input name='conv_type' type='hidden' value='date'>");
    el.append( els.join('') );
  }

  /*
   * revert a dropped field to its source position
   * bound to klick event of remove button
   */
  function revert_field(event, el) {
    var field = $( $(el).parents('.source')[0] ),
        parent = $( $(field).parents('.field')[0] ),
        src_el = src_container.find("[data-source]=" + parent.attr('data-source'));
    field.remove();
    $('.options',parent).remove();
    //no more fields kick class and conv_type too
    if($('.source',parent).length<1){
      parent.removeClass('dropped');
      $("input[name='conv_type']",el).remove();
    }
    src_el.show().css({'left' : '', 'top' : ''}); // reset position
  }

});

/** TODO: make a class structure for this
//widget factory
//$.widget => create
// testing with => qunitjs.com

sk.Csv = function(){
  //instance method
  this.list_el;
};
sk.Csv.prototype = {

  revert_field : function(){
    this.list_el;
  }
}
*/
