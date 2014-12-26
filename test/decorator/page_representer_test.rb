require 'test_helper'
require 'roar/decorator'
require 'active_support/core_ext/object/to_query'

class PageRepresenterTest < MiniTest::Spec
  let(:songs) do
    [
      OpenStruct.new(:name => 'Thriller'),
      OpenStruct.new(:name => 'One More Time'),
      OpenStruct.new(:name => 'Good Vibrations')
    ]
  end

  class SongRepresenter < Roar::Decorator
    include Roar::JSON

    property :name
  end

  class SongsRepresenter < Roar::Decorator
    include Roar::JSON
    include Roar::Contrib::Decorator::PageRepresenter

    collection :songs,
      :exec_context => :decorator,
      :decorator => SongRepresenter

    def songs
      represented
    end

    def page_url(args)
      "http://www.roar-contrib.com/songs?#{args.to_query}"
    end
  end

  describe 'without #page_url defined' do
    class NotImplementedSongsRepresenter < Roar::Decorator
      include Roar::JSON
      include Roar::Contrib::Decorator::PageRepresenter

      collection :songs,
        :exec_context => :decorator,
        :decorator => SongRepresenter

      def songs
        represented
      end
    end

    it 'raises NotImplementedError' do
      proc {
        NotImplementedSongsRepresenter.prepare(songs.paginate()).to_json
      }.must_raise NotImplementedError
    end
  end

  describe 'without CollectionRepresenter' do
    describe 'using WillPaginate' do
      require "will_paginate/array"

      it 'renders a paginated response with no previous or next page' do
        SongsRepresenter
          .prepare(songs.paginate())
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=1&per_page=30"}],"songs":[{"name":"Thriller"},{"name":"One More Time"},{"name":"Good Vibrations"}]}'
      end

      it 'renders a paginated response with a previous and next page' do
        SongsRepresenter
          .prepare(songs.paginate(:page => 2, :per_page => 1))
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=2&per_page=1"},{"rel":"next","href":"http://www.roar-contrib.com/songs?page=3&per_page=1"},{"rel":"previous","href":"http://www.roar-contrib.com/songs?page=1&per_page=1"}],"songs":[{"name":"One More Time"}]}'
      end

      it 'renders a paginated response with a previous and no next page' do
        SongsRepresenter
          .prepare(songs.paginate(:page => 3, :per_page => 1))
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=3&per_page=1"},{"rel":"previous","href":"http://www.roar-contrib.com/songs?page=2&per_page=1"}],"songs":[{"name":"Good Vibrations"}]}'
      end

      it 'renders a paginated response with a next page and no previous page' do
        SongsRepresenter
          .prepare(songs.paginate(:page => 1, :per_page => 1))
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=1&per_page=1"},{"rel":"next","href":"http://www.roar-contrib.com/songs?page=2&per_page=1"}],"songs":[{"name":"Thriller"}]}'
      end
    end

    describe 'using Kaminari' do
      require 'kaminari'
      require 'kaminari/models/array_extension'

      it 'renders a paginated response with no previous or next page' do
        SongsRepresenter
          .prepare(Kaminari.paginate_array(songs).page)
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=1&per_page=25"}],"songs":[{"name":"Thriller"},{"name":"One More Time"},{"name":"Good Vibrations"}]}'
      end

      it 'renders a paginated response with a previous and next page' do
        SongsRepresenter
          .prepare(Kaminari.paginate_array(songs).page(2).per(1))
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=2&per_page=1"},{"rel":"next","href":"http://www.roar-contrib.com/songs?page=3&per_page=1"},{"rel":"previous","href":"http://www.roar-contrib.com/songs?page=1&per_page=1"}],"songs":[{"name":"One More Time"}]}'
      end

      it 'renders a paginated response with a previous and no next page' do
        SongsRepresenter
          .prepare(Kaminari.paginate_array(songs).page(3).per(1))
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=3&per_page=1"},{"rel":"previous","href":"http://www.roar-contrib.com/songs?page=2&per_page=1"}],"songs":[{"name":"Good Vibrations"}]}'
      end

      it 'renders a paginated response with a next page and no previous page' do
        SongsRepresenter
          .prepare(Kaminari.paginate_array(songs).page(1).per(1))
          .to_json
          .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=1&per_page=1"},{"rel":"next","href":"http://www.roar-contrib.com/songs?page=2&per_page=1"}],"songs":[{"name":"Thriller"}]}'
      end
    end
  end

  describe 'HAL' do
    require "will_paginate/array"

    class HalSongsRepresenter < Roar::Decorator
      include Roar::JSON::HAL
      include Roar::Contrib::Decorator::PageRepresenter

      collection :songs,
        :exec_context => :decorator,
        :decorator => SongRepresenter

      def songs
        represented
      end

      def page_url(args)
        "http://www.roar-contrib.com/songs?#{args.to_query}"
      end
    end

    it 'renders a paginated response with no previous or next page' do
      HalSongsRepresenter
        .prepare(songs.paginate())
        .to_json
        .must_equal '{"total_entries":3,"_links":{"self":{"href":"http://www.roar-contrib.com/songs?page=1&per_page=30"}},"songs":[{"name":"Thriller"},{"name":"One More Time"},{"name":"Good Vibrations"}]}'
    end
  end

  describe 'with CollectionRepresenter' do
    require "will_paginate/array"

    class TopSongRepresenter < Roar::Decorator
      include Roar::JSON

      property :name
    end

    class TopSongsRepresenter < Roar::Decorator
      include Roar::JSON
      include Roar::Contrib::Decorator::PageRepresenter
      include Roar::Contrib::Decorator::CollectionRepresenter

      def page_url(args)
        "http://www.roar-contrib.com/songs?#{args.to_query}"
      end
    end

    it 'renders a paginated response with no previous or next page' do
      TopSongsRepresenter
        .prepare(songs.paginate())
        .to_json
        .must_equal '{"total_entries":3,"links":[{"rel":"self","href":"http://www.roar-contrib.com/songs?page=1&per_page=30"}],"top_songs":[{"name":"Thriller"},{"name":"One More Time"},{"name":"Good Vibrations"}]}'
    end
  end
end
