require 'test_helper'
require 'roar/decorator'

class CollectionRepresenterTest < MiniTest::Spec
  class SongRepresenter < Roar::Decorator
    include Roar::Representer::JSON

    property :name
  end

  class SongsRepresenter < Roar::Decorator
    include Roar::Representer::JSON
    include Roar::Contrib::Decorator::CollectionRepresenter
  end

  let(:songs) do
    [
      OpenStruct.new(:name => 'Thriller'),
      OpenStruct.new(:name => 'One More Time'),
      OpenStruct.new(:name => 'Good Vibrations')
    ]
  end

  it 'renders a valid collection' do
    SongsRepresenter
      .prepare(songs)
      .to_json
      .must_equal '{"songs":[{"name":"Thriller"},{"name":"One More Time"},{"name":"Good Vibrations"}]}'
  end
end
