$ ->
  $('[data-hook="add_product_name"]').find('.variant_autocomplete').variantAutocomplete()

  $(".close-modal").click (e) ->
    e.preventDefault()
    $(this).closest(".review-overlay").removeClass("visible")

  actionsRequiringReview = []
  $(".review-overlay").each ->
    actionsRequiringReview.push $(this).data("action")

  $.each actionsRequiringReview, (index, value) ->
    $("##{value}-event-button").click (e) ->
      e.preventDefault()
      # Prevent any UJS events.
      e.stopPropagation()

      $("##{value}-overlay").addClass("visible")
