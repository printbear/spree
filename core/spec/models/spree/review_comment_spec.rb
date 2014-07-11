require 'spec_helper'

describe Spree::ReviewComment do
  describe "#valid?" do
    subject { described_class.new(params).valid? }

    let(:params) do
      {
        user: mock_model(Spree::LegacyUser),
        order: mock_model(Spree::Order),
        comment: "Some Comment"
      }
    end

    context "when the user is missing" do
      before { params[:user] = nil }
      it { should be_false }
    end

    context "when the order is missing" do
      before { params[:order] = nil }
      it { should be_false }
    end

    context "when the comment is missing" do
      before { params[:comment] = nil }
      it { should be_false }
    end

    context "when the comment user and order are present" do
      it { should be_true }
    end
  end
end
