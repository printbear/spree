Spree::OrdersController.class_eval do
  before_filter :set_order, only: [:update]
  before_filter :sanitize_line_items

  def update
    if @order.update_attributes(params[:order])
      render :edit and return unless apply_coupon_code

      @order.line_items = @order.line_items.select {|li| li.quantity > 0 }
      @order.restart_checkout_flow
      fire_event('spree.order.contents_changed')
      respond_with(@order) do |format|
        format.html do
          if params.has_key?(:checkout)
            @order.next_transition.run_callbacks if @order.cart?
            redirect_to checkout_state_path(@order.checkout_steps.first)
          else
            redirect_to cart_path
          end
        end
      end
    else
      respond_with(@order)
    end
  end

  private

  def set_order
    # Ensures @order is never nil.
    # Prevents edge case: Modifying a completed order
    @order = current_order(true)
  end

  def sanitize_line_items
    # Ensures an order with no line items won't try to update them if present in params.
    # Prevents edge case: Modifying a destroyed order.
    params[:order].delete(:line_items_attributes) if @order.line_items.empty?
  end
end
