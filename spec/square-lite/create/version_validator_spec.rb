# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Create::VersionValidator do
  subject(:run_validation)  do
    described_class.new(versions_by_ids).validate!(data)
  end

  let(:versions_by_ids) { { thing1: 1, thing2: 2 } }

  let(:data)   { [thing1, thing2].compact }
  let(:thing1) { { id: :thing1, version: 1 } }
  let(:thing2) { { id: :thing2, version: 2 } }

  def is_expeced_to_raise(error_type)
    expect { run_validation }.to raise_error(error_type)
  end

  describe '#validate!' do
    it { is_expected.to be true }

    context 'with a stale version' do
      before { thing2[:version] = 1 }

      it { is_expeced_to_raise(SquareLite::StaleVersionError) }
    end

    context 'with stale cache' do
      before { thing2[:version] = 3 }

      it { is_expeced_to_raise(SquareLite::StaleVersionCacheError) }
    end

    context 'with a missing version' do
      before { thing1.delete(:version) }

      it { is_expeced_to_raise(SquareLite::MissingVersionError) }
    end

    context 'when empty' do
      let(:data) { [] }

      it { is_expected.to be true }
    end
  end
end
