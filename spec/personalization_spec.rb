require 'spec_helper'
require 'stream'

describe Stream::PersonalizationClient do
  before do
    client = Stream::Client.new('key', 'secret')
    @personalization = client.personalization
  end

  def stub_and_expect(method, endpoint, params, data)
    expected = {
      method: method,
      endpoint: endpoint,
      auth: /^([0-9a-z\-_]+)\.([0-9a-z\-_]+)\.([0-9a-z\-_]+)$/i,
      params: params,
      data: data
    }
    expect(@personalization).to receive(:make_request)
        .with(
          expected[:method],
          expected[:endpoint],
          expected[:auth],
          expected[:params],
          expected[:data]
        )
  end

  describe :get do
    it 'should send get request correctly' do
      stub_and_expect(:get, '/example/', { foo: 'bar', baz: 'qux' }, {})
      @personalization.get('example', foo: 'bar', baz: 'qux')
    end
  end

  describe :post do
    it 'should send post request correctly' do
      stub_and_expect(:post, '/example/', { red: 'blue' }, data: { foo: 'bar', baz: { qux: 42 } })
      @personalization.post('example', { red: 'blue' }, foo: 'bar', baz: { qux: 42 })
    end
  end

  describe :delete do
    it 'should send delete request correctly' do
      stub_and_expect(:delete, '/example/', { foo: 'bar', baz: 'qux' }, {})
      @personalization.delete('example', foo: 'bar', baz: 'qux')
    end
  end
end
