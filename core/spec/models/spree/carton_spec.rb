require 'spec_helper'

describe Spree::Carton do
  describe "#create" do
    subject { create(:carton) }

    it { expect { subject }.to_not raise_error }
  end
end
