# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Create do
  let(:client) { described_class.new(build_generic_client, search) }
  let(:search) { double('SquareLite::Search', catalog: catalog) }

  let(:catalog) { double('catalog', all: catalog_objects) }
  let(:catalog_objects) { [] }

  describe '#for' do
    context 'catalog' do
      it { expect(client.for(:catalog)).to_not be_nil }
    end
  end

  describe '#catalog' do
    context 'empty catalog' do
      it { expect(client.catalog).to_not be_nil }
    end

    context 'with existing catalog objects' do
      let(:catalog_objects) { [{ 'id' => 'object1', 'version' => 1 }] }

      before { expect(catalog).to receive(:all).and_return(catalog_objects) }

      it { expect(client.catalog).to_not be_nil }
    end
  end
end
