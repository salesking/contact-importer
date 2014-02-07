jQuery ->
  $('#target-fields').on 'click', '.kill', (e) -> revertField(e, this)

  $('#source-fields').delegate '.field:not(.ui-draggable)', 'mouseenter', ->
    $(this).draggable revert: 'invalid'

  $('#target-fields').delegate '.field:not(.ui-droppable)', 'mouseenter', ->
    $(this).droppable
      accept: "#source-fields li",
      hoverClass: "over",
      drop: (event, ui) -> dropField($(this), ui)

  dropField = (el, ui) ->
    addFields el, ui
    addEnumFields(el) if $('.target', el).attr('data-enum') != undefined
    addDateFields(el) if $('.target', el).attr('data-format') == 'date'

  addFields = (el, ui) ->
    $('.target', el).after "<div class='source' " +
      "data-name='" + ui.draggable.data('name') + "' data-source='" + ui.draggable.data('source') + "'>" +
      "<div>" + ui.draggable.text() + "</div>" +
      "<div class='map_actions'><div class='kill'> x </div></div>" +
      "</div>"
    ui.draggable.hide()
    if $('.source', el).length > 1 && $("input[name='conv_type']", el).length == 0
      el.append "<input name='conv_type' type='hidden' value='join'>"
    el.addClass 'dropped'

  addEnumFields = (el) ->
    els = ["<div class='options'>"]

    $.each $('.target', el).attr('data-enum').split(','), ->
      #clean "[] from strings, comming from ary markup
      name = this.replace( /["\[\]]/g, '')
      els.push "<div> <input class='mini' name='" + name + "' type='text'> <label>=> " + name + "</label></div>"
    els.push "<input name='conv_type' type='hidden' value='enum'>"
    els.push "</div>"
    el.append els.join('')

  addDateFields = (el) ->
    els = ["<div class='options'>"]
    els.push "<div> <input class='mini' name='date' type='text'> <label>=> Target format YYYY.MM.DD</label></div>"
    els.push "<div class='help-block'>Use Placeholders %Y %m %d describing the incoming date format.</div>"
    els.push "</div>"
    els.push "<input name='conv_type' type='hidden' value='date'>"
    el.append els.join('')

  revertField = (event, el) ->
    field = $($(el).parents('.source')[0])
    parent = $($(field).parents('.field')[0])
    srcElement = $("#source-fields li[data-source=" + field.data('source') + "]")
    field.remove()
    $('.options', parent).remove()
    if $('.source', parent).length == 0
      parent.removeClass 'dropped'
      $("input[name='conv_type']", el).remove()
    srcElement.show().css left: '', top: ''

  $('#target-fields .field').trigger 'mouseenter'

  $(':submit').click ->
    mappings = []
    $.each $('#target-fields .field.dropped'), (i) ->
      el = $(this)
      sourceIDs = [];
      $.each $('.source', el), -> sourceIDs.push $(this).attr('data-source')
      mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][source]' value='" + sourceIDs.join(',') + "'>"
      mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][target]' value='" + $('.target', el).attr('data-target') + "'>"
      if $("input[name='conv_type']", el).length > 0
        mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][conv_type]' value='" + $("input[name='conv_type']", el).val() + "'>"
      if $('.options', el).length > 0
        opts = {};
        $.each $('.options :text', el), -> opts[$(this).attr('name')] = $(this).val()
        mappings.push "<input type='hidden' name='mapping[mapping_elements_attributes][" + i + "][conv_opts]' value='" + JSON.stringify(opts) + "'>"
    $('form').append mappings.join('')
