require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OpenGraph do
  describe '#initialize' do
    context 'with invalid src' do
      it 'should set title and url the same as src' do
        og = OpenGraph.new('invalid')
        expect(og.src).to eq('invalid')
        expect(og.title).to eq('invalid')
        expect(og.url).to eq('invalid')
      end
    end

    context 'with no fallback' do
      it 'should get values from opengraph metadata' do
        response = double(body: File.open("#{File.dirname(__FILE__)}/../view/opengraph.html", 'r', &:read))
        allow(RedirectFollower).to receive(:new) { double(resolve: response) }

        og = OpenGraph.new('http://test.host', false)
        expect(og.src).to eq('http://test.host')
        expect(og.title).to eq('OpenGraph Title')
        expect(og.type).to eq('article')
        expect(og.url).to eq('http://test.host')
        expect(og.description).to eq('My OpenGraph sample site for Rspec')
        expect(og.images).to eq(['http://test.host/images/rock1.jpg', 'http://test.host/images/rock2.jpg'])
        expect(og.original_images).to eq(['http://test.host/images/rock1.jpg', '/images/rock2.jpg'])
        expect(og.metadata).to eq(
          title: [{ _value: 'OpenGraph Title' }],
          type: [{ _value: 'article' }],
          url: [{ _value: 'http://test.host' }],
          description: [{ _value: 'My OpenGraph sample site for Rspec' }],
          image: [
            {
              _value: 'http://test.host/images/rock1.jpg',
              width: [{ _value: '300' }],
              height: [{ _value: '300' }]
            },
            {
              _value: '/images/rock2.jpg',
              height: [{ _value: '1000' }]
            }
          ],
          locale: [
            {
              _value: 'en_GB',
              alternate: [
                { _value: 'fr_FR' },
                { _value: 'es_ES' }
              ]
            }
          ]
        )
      end
    end

    context 'with fallback' do
      context 'when website has opengraph metadata' do
        it 'should get values from opengraph metadata' do
          response = double(body: File.open("#{File.dirname(__FILE__)}/../view/opengraph.html", 'r', &:read))
          allow(RedirectFollower).to receive(:new) { double(resolve: response) }

          og = OpenGraph.new('http://test.host')
          expect(og.src).to eq('http://test.host')
          expect(og.title).to eq('OpenGraph Title')
          expect(og.type).to eq('article')
          expect(og.url).to eq('http://test.host')
          expect(og.description).to eq('My OpenGraph sample site for Rspec')
          expect(og.images).to eq(['http://test.host/images/rock1.jpg', 'http://test.host/images/rock2.jpg'])
        end
      end

      context 'when website has no opengraph metadata' do
        it 'should lookup for other data from website' do
          response = double(body: File.open("#{File.dirname(__FILE__)}/../view/opengraph_no_metadata.html", 'r', &:read))
          allow(RedirectFollower).to receive(:new) { double(resolve: response) }

          og = OpenGraph.new('http://test.host/child_page')
          expect(og.src).to eq('http://test.host/child_page')
          expect(og.title).to eq('OpenGraph Title Fallback')
          expect(og.type).to be_nil
          expect(og.url).to eq('http://test.host/child_page')
          expect(og.description).to eq('Short Description Fallback')
          expect(og.images).to eq(['http://test.host/images/wall1.jpg', 'http://test.host/images/wall2.jpg'])
        end
      end

      context 'when website has no opengraph metadata nor description' do
        it 'should lookup for other data from website' do
          response = double(body: File.open("#{File.dirname(__FILE__)}/../view/opengraph_no_meta_nor_description.html", 'r', &:read))
          allow(RedirectFollower).to receive(:new) { double(resolve: response) }

          og = OpenGraph.new('http://test.host/child_page')
          expect(og.src).to eq('http://test.host/child_page')
          expect(og.title).to eq('OpenGraph Title Fallback')
          expect(og.type).to be_nil
          expect(og.url).to eq('http://test.host/child_page')
          expect(og.description).to eq('No description meta here.')
          expect(og.images).to eq(['http://test.host/images/wall1.jpg', 'http://test.host/images/wall2.jpg'])
        end
      end
    end

    context 'with body' do
      it 'should parse body instead of downloading it' do
        content = File.read("#{File.dirname(__FILE__)}/../view/opengraph.html")
        expect(RedirectFollower).not_to receive(:new)

        og = OpenGraph.new(content)
        expect(og.src).to eq(content)
        expect(og.title).to eq('OpenGraph Title')
        expect(og.type).to eq('article')
        expect(og.url).to eq('http://test.host')
        expect(og.description).to eq('My OpenGraph sample site for Rspec')
        expect(og.images).to eq(['http://test.host/images/rock1.jpg', '/images/rock2.jpg'])
      end
    end
  end
end
