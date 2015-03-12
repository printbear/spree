class Spree::OrderShipping
  def initialize(order)
    @order = order
  end

  # returns the carton created. raises on failure.
  def ship_shipment(shipment, external_number: nil)
    ship(
      inventory_units: shipment.inventory_units,
      stock_location: shipment.stock_location,
      address: shipment.address,
      shipping_method: shipment.shipping_method,
      shipped_at: Time.now,
      external_number: external_number,
    )
  end

  # returns the carton created. raises on failure.
  def ship(inventory_units:, stock_location:, address:, shipping_method:, shipped_at: Time.now, external_number: nil)
    carton = nil

    Spree::InventoryUnit.transaction do
      inventory_units.each &:ship!

      carton = Spree::Carton.create!(
        stock_location: stock_location,
        address: address,
        shipping_method: shipping_method,
        inventory_units: inventory_units,
        shipped_at: shipped_at,
        external_number: external_number,
      )
    end

    inventory_units.map(&:shipment).uniq.each do |shipment|
      if shipment.inventory_units.all?(&:shipped?)
        # TODO: make OrderContents#ship_shipment call Shipment#ship! rather than
        # having Shipment#ship! call OrderContents#ship_shipment. We only really
        # need this `update_columns` for the specs, until we make that change.
        shipment.update_columns(state: 'shipped', shipped_at: Time.now)

        if stock_location.fulfillable? # e.g. digital gift cards that aren't actually shipped
          # TODO: send inventory units instead of shipment
          Spree::ShipmentMailer.shipped_email(shipment).deliver
        end
      end
    end

    fulfill_order_stock_locations(stock_location)
    update_order_state

    carton
  end

  private

  # This is for exchanges
  def fulfill_order_stock_locations(stock_location)
    Spree::OrderStockLocation.fulfill_for_order_with_stock_location(@order, stock_location)
  end

  def update_order_state
    new_state = Spree::OrderUpdater.new(@order).update_shipment_state
    @order.update_columns(
      shipment_state: new_state,
      updated_at: Time.now,
    )
  end
end