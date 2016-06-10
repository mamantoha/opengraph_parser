require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RedirectFollower do
  describe '#resolve' do
    let(:url) { 'http://test.host' }
    let(:https_url) { 'https://test.host' }
    let(:mock_res) { double(body: 'Body is here.') }
    let(:mock_redirect) do
      m = double(body: %(<body><a href="http://new.test.host"></a></body>), is_a?: Net::HTTPRedirection)
      allow(m).to receive(:[]).and_return(nil)
      m
    end

    context 'with no redirection' do
      it 'should return the response' do
        uri = URI.parse(URI.escape(url))

        http = Net::HTTP.new(uri.host, uri.port)
        expect(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(http)
        expect(http).to receive(:request_get).and_return(mock_res)

        res = RedirectFollower.new(url).resolve
        expect(res.body).to eq('Body is here.')
        expect(res.redirect_limit).to eq(RedirectFollower::REDIRECT_DEFAULT_LIMIT)
      end

      describe 'and uri scheme is HTTPS' do
        it 'should use https method to retrieve the uri' do
          uri = URI.parse(URI.escape(https_url))

          https = Net::HTTP.new(uri.host, uri.port)
          expect(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(https)
          expect(https).to receive(:request_get).and_return(mock_res)

          res = RedirectFollower.new(https_url).resolve
          expect(res.body).to eq('Body is here.')
          expect(res.redirect_limit).to eq(RedirectFollower::REDIRECT_DEFAULT_LIMIT)
        end
      end

      describe 'and has headers option' do
        it 'should add headers when retrieve the uri' do
          uri = URI.parse(URI.escape(url))

          http = Net::HTTP.new(uri.host, uri.port)
          expect(Net::HTTP).to receive(:new).with(uri.host, uri.port).and_return(http)
          expect(http).to receive(:request_get).and_return(mock_res)
          res = RedirectFollower.new(url, headers: { 'User-Agent' => 'My Custom User-Agent' }).resolve
          expect(res.body).to eq('Body is here.')
          expect(res.redirect_limit).to eq(RedirectFollower::REDIRECT_DEFAULT_LIMIT)
        end
      end
    end

    context 'with redirection' do
      it 'should follow the link in redirection' do
        uri = URI.parse(URI.escape(url))

        http = Net::HTTP.new(uri.host, uri.port)
        expect(Net::HTTP).to receive(:new).twice.and_return(http)
        expect(http).to receive(:request_get).twice.and_return(mock_redirect, mock_res)

        res = RedirectFollower.new(url).resolve
        expect(res.body).to eq('Body is here.')
        expect(res.redirect_limit).to eq(RedirectFollower::REDIRECT_DEFAULT_LIMIT - 1)
      end
    end

    context 'with unlimited redirection' do
      it 'should raise TooManyRedirects error' do
        uri = URI.parse(URI.escape(url))

        http = Net::HTTP.new(uri.host, uri.port)
        allow(Net::HTTP).to receive(:new).and_return(http)
        allow(http).to receive(:request_get).and_return(mock_redirect)

        expect do
          RedirectFollower.new(url).resolve
        end.to raise_error(RedirectFollower::TooManyRedirects)
      end
    end
  end
end
