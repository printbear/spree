require 'spec_helper'

module Spree
  describe Spree::Order do
    let(:order) { stub_model(Spree::Order) }
    let(:updater) { Spree::OrderUpdater.new(order) }

    before do
      # So that Payment#purchase! is called during processing
      Spree::Config[:auto_capture] = true

      order.stub_chain(:line_items, :empty?).and_return(false)
      order.stub :total => 100
    end

    it 'processes all payments' do
      payment_1 = create(:payment, :amount => 50)
      payment_2 = create(:payment, :amount => 50)
      order.stub(:pending_payments).and_return([payment_1, payment_2])

      order.process_payments!
      updater.update_payment_state
      order.payment_state.should == 'paid'

      payment_1.should be_completed
      payment_2.should be_completed
    end

    it 'does not go over total for order' do
      payment_1 = create(:payment, :amount => 50)
      payment_2 = create(:payment, :amount => 50)
      payment_3 = create(:payment, :amount => 50)
      order.stub(:pending_payments).and_return([payment_1, payment_2, payment_3])

      order.process_payments!
      updater.update_payment_state
      order.payment_state.should == 'paid'

      payment_1.should be_completed
      payment_2.should be_completed
      payment_3.should be_checkout
    end

    it "does not use failed payments" do
      payment_1 = create(:payment, :amount => 50)
      payment_2 = create(:payment, :amount => 50, :state => 'failed')
      order.stub(:pending_payments).and_return([payment_1])

      payment_2.should_not_receive(:process!)

      order.process_payments!
    end

    context "#authorize_payments!" do
      let(:payment) { stub_model(Spree::Payment) }
      before { order.stub :pending_payments => [payment], :total => 10 }
      subject { order.authorize_payments! }

      it "processes payments with authorize!" do
        expect(payment).to receive(:authorize!)
        subject
      end

      it { should be_true }
    end

    context "#purchase_payments!" do
      let(:payment) { stub_model(Spree::Payment) }
      before { order.stub :pending_payments => [payment], :total => 10 }
      subject { order.purchase_payments! }

      it "processes payments with purchase!" do
        expect(payment).to receive(:purchase!)
        subject
      end

      it { should be_true }
    end

    context "#capture_payments!" do
      let(:payment) { stub_model(Spree::Payment) }
      before { order.stub :pending_payments => [payment], :total => 10 }
      subject { order.capture_payments! }

      it "processes payments with capture!" do
        expect(payment).to receive(:capture!)
        subject
      end
    end
  end
end
