$(document).ready ->
  return unless $('#listing_product_stock').length > 0
  
  $('body').on 'click', '#listing_product_stock .fa-edit', (ev) ->
    ev.preventDefault()
    stockItemId = $(ev.currentTarget).data('id')
    hideReadOnlyElements(stockItemId)
    resetCountOnHandInput(stockItemId)
    showEditForm(stockItemId)

  $('body').on 'click', '#listing_product_stock .fa-void', (ev) ->
    ev.preventDefault()
    stockItemId = $(ev.currentTarget).data('id')
    hideEditForm(stockItemId)
    showReadOnlyElements(stockItemId)

  $('body').on 'click', '#listing_product_stock .fa-check', (ev) ->
    ev.preventDefault()
    stockItemId = $(ev.currentTarget).data('id')
    stockLocationId = $(ev.currentTarget).data('location-id')
    countOnHandDiff = calculateCountOnHandDiff(stockItemId)
    backorderable = $("#backorderable-#{stockItemId}").prop("checked")
    Spree.ajax
      url: "#{Spree.routes.stock_items_api(stockLocationId)}/#{stockItemId}"
      type: "PUT"
      data:
        stock_item:
          backorderable: backorderable
          count_on_hand: countOnHandDiff
      success: (stockItem) =>
        updateSuccessHandler(stockItem)
        show_flash("success", Spree.translations.updated_successfully)
      error: (errorData) ->
        show_flash("error", errorData.responseText)

  $('body').on 'click', '#listing_product_stock .fa-plus', (ev) ->
    ev.preventDefault()
    variantId = $(ev.currentTarget).data('variant-id')
    countInput = $("#variant-count-on-hand-#{variantId}")
    locationSelect = $("#variant-stock-location-#{variantId}")
    locationSelectContainer = locationSelect.siblings('.select2-container')
    resetAddStockItemValidationErrors(locationSelectContainer, countInput)
    validateAddStockItemForm(locationSelect, locationSelectContainer, countInput)
    return if addStockItemHasErrors(locationSelectContainer, countInput)

    stockLocationId = locationSelect.val()
    backorderable = $("#variant-backorderable-#{variantId}").prop("checked")
    Spree.ajax
      url: "#{Spree.routes.stock_items_api(stockLocationId)}"
      type: "POST"
      data:
        stock_item:
          variant_id: variantId
          backorderable: backorderable
          count_on_hand: countInput.val()
      success: (stockItem) =>
        createSuccessHandler(stockItem)
        show_flash("success", Spree.translations.created_successfully)
      error: (errorData) ->
        show_flash("error", errorData.responseText)

  showReadOnlyElements = (stockItemId) ->
    toggleReadOnlyElements(stockItemId, true)

  hideReadOnlyElements = (stockItemId) ->
    toggleReadOnlyElements(stockItemId, false)

  toggleReadOnlyElements = (stockItemId, show) ->
    disabledValue = if show then 'disabled' else null
    textCssDisplay = if show then 'block' else 'none'
    toggleButtonVisibility('edit', stockItemId, show)
    $("#backorderable-#{stockItemId}").prop('disabled', disabledValue)
    $("#count-on-hand-#{stockItemId} span").css('display', textCssDisplay)

  showEditForm = (stockItemId) ->
    toggleEditFormVisibility(stockItemId, true)

  hideEditForm = (stockItemId) ->
    toggleEditFormVisibility(stockItemId, false)

  toggleEditFormVisibility = (stockItemId, show) ->
    disabledValue = if show then null else 'disabled'
    inputCssDisplay = if show then 'block' else 'none'
    toggleButtonVisibility('void', stockItemId, show)
    toggleButtonVisibility('check', stockItemId, show)
    $("#backorderable-#{stockItemId}").prop('disabled', disabledValue)
    $("#count-on-hand-#{stockItemId} input[type='number']").css('display', inputCssDisplay)

  toggleButtonVisibility = (buttonIcon, stockItemId, show) ->
    cssDisplay = if show then 'inline-block' else 'none'
    $(".fa-#{buttonIcon}[data-id='#{stockItemId}']").css('display', cssDisplay)

  resetCountOnHandInput = (stockItemId) ->
    tableCell = $("#count-on-hand-#{stockItemId}")
    countText = tableCell.find('span').text().trim()
    tableCell.find("input[type='number']").val(countText)

  calculateCountOnHandDiff = (stockItemId) ->
    currentValue = parseInt($("#count-on-hand-#{stockItemId} span").text(), 10)
    updatedValue = parseInt($("#count-on-hand-#{stockItemId} input[type='number']").val(), 10)
    updatedValue - currentValue
  
  updateSuccessHandler = (stockItem) ->
    $("#count-on-hand-#{stockItem.id} span").text(stockItem.count_on_hand)
    hideEditForm(stockItem.id)
    showReadOnlyElements(stockItem.id)

  createSuccessHandler = (stockItem) ->
    variantId = stockItem.variant_id
    stockLocationId = stockItem.stock_location_id
    stockLocationSelect = $("#variant-stock-location-#{variantId}")
    
    selectedStockLocationOption = stockLocationSelect.find("option[value='#{stockLocationId}']")
    stockLocationName = selectedStockLocationOption.text().trim()
    selectedStockLocationOption.remove()
    
    rowTemplate = Handlebars.compile($('#stock-item-count-for-location-template').html())
    $("tr[data-variant-id='#{variantId}']:last").before(
      rowTemplate
        id: stockItem.id
        variantId: variantId
        stockLocationId: stockLocationId
        stockLocationName: stockLocationName
        countOnHand: stockItem.count_on_hand
        backorderable: stockItem.backorderable
    )
    resetTableRowStyling(variantId)

    if stockLocationSelect.find('option').length is 1 # blank value
      stockLocationSelect.parents('tr:first').remove()
    else
      stockLocationSelect.select2()
      $("#variant-count-on-hand-#{variantId}").val("")

    resetParentRowspan(variantId)

  resetAddStockItemValidationErrors = (locationSelectContainer, countInput) ->
    countInput.removeClass('error')
    locationSelectContainer.removeClass('error')

  validateAddStockItemForm = (locationSelect, locationSelectContainer, countInput) ->
    if locationSelect.val() is ""
      locationSelectContainer.addClass('error')

    if isNaN(parseInt(countInput.val(), 10))
      countInput.addClass('error')

  addStockItemHasErrors = (locationSelectContainer, countInput) ->
    locationSelectContainer.hasClass('error') or countInput.hasClass('error')

  resetTableRowStyling = (variantId) ->
    tableRows = $("tr[data-variant-id='#{variantId}']")
    tableRows.removeClass('even odd')
    for i in [0..tableRows.length]
      rowClass = if (i + 1) % 2 is 0 then 'even' else 'odd'
      tableRows.eq(i).addClass(rowClass)

  resetParentRowspan = (variantId) ->
    newRowspan = $("tr[data-variant-id='#{variantId}']").length + 1
    $("#spree_variant_#{variantId} > td").attr('rowspan', newRowspan)
