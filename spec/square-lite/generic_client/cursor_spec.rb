require 'spec_helper'

RSpec.describe SquareLite::GenericClient::Cursor do
  let(:path)   { 'v2/not/real' }
  let(:client) { SquareLite::GenericClient.paginated(nil, build_auth) }
  let(:request_params) { nil }
  let(:cursor) { client.request(:post, path, params: request_params) }

  # avoid infinite loops on cursor always having a value
  around { |example| Timeout.timeout(1) { example.run } }

  let(:objects) { { objects: [{ name: 'object_name1' }] } }
  let(:object)  { { object:  [name: 'object_name'] } }
  let(:related) { { related_objects: [{ id: 'related_obj_id' }] } }


  describe 'iterates' do
    let!(:request) { stub_sq(path, :post, body: resp_body) }

    context 'over "objects"' do
      let(:resp_body) { build_body(**objects) }

      it 'yields object data' do
        cursor.each do |data|
          expect(data).to eq({'name' => 'object_name1'})
        end
      end

      context 'with many' do
        let(:objects) do
          { objects: [
            { name: 'object_name1' },
            { name: 'object_name2' }
          ]}
        end

        it 'yields all objects in response' do
          expected = [
            {name: 'object_name1'},
            {name: 'object_name2'}
          ]

          cursor.each do |data|
            expect(data).to eq(expected.shift.stringify_keys)
          end
        end
      end
    end

    context 'over "object"' do
      let(:resp_body) { build_body(**object) }

      it 'yields object data' do
        cursor.each do |data|
          expect(data).to eq({'name' => 'object_name'})
        end
      end

      context 'without related_objects' do
        it 'yields nil' do
          cursor.each do |data, related|
            expect(related).to eq(nil)
          end
        end
      end
    end

    context 'with related_objects' do
      #let(:request) { stub_sq(path, :post, body: resp_body) }
      let(:resp_body) { build_body(**objects.merge(related)) }
      let(:request_params) { { include_related_objects: true } }

      before { expect_req_body(request, request_params) }

      it 'yields the related_objects' do
        related_arg = {
          'related_obj_id' => [{ 'id' => 'related_obj_id' }]
        }

        cursor.each do |data, related_data|
          expect(related_data).to eq(related_arg)
        end
      end
    end
  end

  context 'cursor param' do
    let(:resp_body1) { build_body(**objects, cursor: 'cursor_value') }
    let(:request1)   { stub_sq(path, :post, body: resp_body1) }

    let(:resp_body2) { build_body(objects: [{ name: 'object_name2' }]) }
    let(:request2)   { stub_sq(path, :post, body: resp_body2) }

    it 'memoizes network requests' do
      expected = [
        {'name' => 'object_name1'},
        {'name' => 'object_name2'}
      ]

      expect_req_body(request1, nil)
      expect(cursor.first).to include(expected.first)
      expect(request1).to have_been_made

      WebMock.reset!

      expect_req_body(request2, {cursor: 'cursor_value'})
      expect(cursor.to_a).to eq(expected)
      expect(request2).to have_been_made
    end
  end
end
