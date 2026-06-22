# frozen_string_literal: true

RSpec.describe HelpScout::API::Client do
  let(:token_value) { JSON.parse(access_token_json)['access_token'] }

  describe '#connection' do
    it 'returns a Faraday connection pointed at the API base URL' do
      conn = described_class.new(authorize: false).connection

      expect(conn).to be_a(Faraday::Connection)
      expect(conn.url_prefix.to_s).to eq(HelpScout::API::BASE_URL)
    end

    context 'when authorization is enabled and an access token is available' do
      it 'sends a Bearer Authorization header on requests' do
        stub = stub_request(:get, api_path('ping'))
               .with(headers: { 'Authorization' => "Bearer #{token_value}" })
               .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

        described_class.new.connection.get('ping')

        expect(stub).to have_been_requested
      end
    end

    context 'when authorization is disabled' do
      it 'does not send an Authorization header' do
        stub = stub_request(:get, api_path('ping'))
               .with { |request| !request.headers.key?('Authorization') }
               .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

        described_class.new(authorize: false).connection.get('ping')

        expect(stub).to have_been_requested
      end
    end
  end
end
