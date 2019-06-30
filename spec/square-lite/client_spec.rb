# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Client do
  let(:client) { build_client }

  describe '#search' do
    let(:things) { [] }
    subject { client.search(*things) }

    it { is_expected.to_not be_nil }

    context 'on catalog' do
      let(:things) { [:catalog] }

      it { is_expected.to_not be_nil }
    end

    context 'item, item_variation' do
      let(:things) { [:item, :item_variation] }

      it { is_expected.to_not be_nil }
    end
  end

  describe '#delete' do
    subject { client.delete }

    it { is_expected.to_not be_nil }
  end

  describe '#create' do
    subject { client.create }

    it { is_expected.to_not be_nil }
  end
end
