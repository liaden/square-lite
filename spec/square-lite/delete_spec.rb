# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SquareLite::Delete do
  let(:ids) { [] }
  let(:where) { nil }

  let(:deleter) { SquareLite::Client.new(test_token).delete }

  describe 'fails validations with' do
    %i[catalog_object customer].each do |resource|
      context "##{resource}" do
        subject { -> { deleter.send(resource, *ids, where: where) } }

        context 'no args' do
          it { is_expected.to raise_error(SquareLite::Delete::NoDeletionCriteriaError) }
        end

        context 'ids and where clause' do
          let(:ids) { %w[1 2 3] }
          let(:where) { [{ 'id' => '1' }] }

          it { is_expected.to raise_error(SquareLite::Delete::AmbiguousDeleteError) }
        end

        describe 'bad search results:' do
          context 'no data found' do
            let(:where) { [] }

            it { is_expected.to raise_error(SquareLite::Delete::NoIdsError) }
          end

          context 'data does not have ID' do
            let(:where) { ['name' => 'something'] }

            it { is_expected.to raise_error(SquareLite::Delete::MissingIdError) }
          end
        end
      end
    end
  end

  describe '#catalog_object' do

    def do_delete
      deleter.catalog_objects(*ids, where: where)
    end

    context 'one id' do
      let(:where) { [{ 'id' => 'obj1_id' }] }
      let!(:request) { stub_sq('v2/catalog/object/obj1_id', :delete, :default_resp) }

      it 'DELETEs /v2/catalog/object/obj1_id' do
        do_delete

        expect(request).to have_been_made
      end
    end

    context 'two ids' do
      let(:where) { [{ 'id' => 'obj1_id' }, { 'id' => 'obj2_id' }] }
      let!(:request) { stub_sq('v2/catalog/batch-delete', :post, :default_resp) }

      it 'POSTs /v2/catalog/batch-delete' do
        expect_req_body(request, object_ids: %w[obj1_id obj2_id])
        do_delete
        expect(request).to have_been_made
      end
    end
  end

  describe '#customer' do
    def do_delete
      deleter.customers(*ids, where: where)
    end

    context 'one id' do
      let(:where) { [{ 'id' => 'obj1_id' }] }
      let!(:request) { stub_sq('v2/customers/obj1_id', :delete, :default_resp) }

      it 'DELETEs /v2/customers/obj1_id' do
        do_delete

        expect(request).to have_been_made
      end
    end

    context 'two ids' do
      let(:where) { [{ 'id' => 'obj1_id' }, { 'id' => 'obj2_id' }] }

      let!(:request1) { stub_sq('v2/customers/obj1_id', :delete, :default_resp) }
      let!(:request2) { stub_sq('v2/customers/obj2_id', :delete, :default_resp) }

      it 'DELETEs /v2/customers/obj1_id' do
        do_delete

        expect(request1).to have_been_made
        expect(request2).to have_been_made
      end
    end
  end
end
