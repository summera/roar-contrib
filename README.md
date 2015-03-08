# roar-contrib [![Build Status](https://travis-ci.org/summera/roar-contrib.svg?branch=master)](https://travis-ci.org/summera/roar-contrib) [![Gem Version](https://badge.fury.io/rb/roar-contrib.svg)](http://badge.fury.io/rb/roar-contrib)
Collection of useful [Roar](https://github.com/apotonick/roar) contributions and extensions. I just released a pre-release as I would like to know what you all think. Cheers!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'roar-contrib'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roar-contrib

## Representers

### Collections with Decorators
When using Decorators, include `Roar::Contrib::Decorator::CollectionRepresenter` to create a Representer for a collection of resources.

```ruby
class SongRepresenter < Roar::Decorator
  include Roar::JSON

  property :name
end

class SongsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::Contrib::Decorator::CollectionRepresenter
end
```

This will create a collection (`songs` in this case) based on the name of the Representer, using the singular representer (SongRepresenter) to serialize each individual resource in the collection. Therefore, a **GET** request to `/songs` would give you:

```json
{
  "songs": [
    {
      "name": "Thriller"
    },
    {
      "name": "One More Time"
    },
    {
      "name": "Good Vibrations"
    }
  ]
}
```

If you need more custom behavior and want to define your own collection, you can do it like so:
```ruby
class SongsRepresenter < Roar::Decorator
  include Roar::JSON

  collection :top_songs,
    :exec_context => :decorator,
    :decorator => TopSong

  def top_songs
    represented
  end
end
```

### Pagination with Decorators
Roar-contrib pagination works with either [will_paginate](https://github.com/mislav/will_paginate) or [Kaminari](https://github.com/amatsuda/kaminari). It is based on Nick Sutterer's [blog post](http://nicksda.apotomo.de/2012/05/ruby-on-rest-6-pagination-with-roar/). You must install one of these for roar-contrib pagination to work. In your Gemfile, include either

```ruby
gem 'will_paginate'
```
or
```ruby
gem 'kaminari'
```

To paginate, include `Roar::Contrib::Decorator::PageRepresenter` and define `page_url` in the paginated Representer like so:

```ruby
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

  # If using roar-rails, url helpers are also available here
  def page_url(args)
    "http://www.roar-contrib.com/songs?#{args.to_query}"
  end
end
```


As you may have guessed, you can combine the `CollectionRepresenter` and `PageRepresenter` to DRY up the example above. **Woot Woot!** :stuck_out_tongue_closed_eyes: :boom:

```ruby
class SongRepresenter < Roar::Decorator
  include Roar::JSON

  property :name
end

class SongsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::Contrib::Decorator::PageRepresenter
  include Roar::Contrib::Decorator::CollectionRepresenter

  def page_url(args)
    "http://www.roar-contrib.com/songs?#{args.to_query}"
  end
end
```

If you are using Rails, your controller(s) may look like the following...

```ruby
# Using will_paginate
class SongsController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  represents :json, Song

  def index
    @songs = Song.paginate :page => params[:page], :per_page => params[:per_page]

    respond_with @songs
  end
end

# Using Kaminari
class SongsController < ActionController::Base
  include Roar::Rails::ControllerAdditions
  represents :json, Song

  def index
    @songs = Song.page(params[:page]).per params[:per_page]

    respond_with @songs
  end
end
```

Now, a **GET** request to `/songs?page=3&per_page=1` would give you:

```json
{
  "total_entries": 3,
  "links": [
    {
      "rel": "self",
      "href": "http://www.roar-contrib.com/songs?page=3&per_page=1"
    },
    {
      "rel": "previous",
      "href": "http://www.roar-contrib.com/songs?page=2&per_page=1"
    }
  ],
  "songs": [
    {
      "name": "Good Vibrations"
    }
  ]
}
```

You can define additional pagination properties in your response such as `per_page` provided by [will_paginate](https://github.com/mislav/will_paginate), or `limit_value` provided by [Kaminari](https://github.com/amatsuda/kaminari), by defining the property in your paginated representer.

```ruby
class SongsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::Contrib::Decorator::PageRepresenter
  include Roar::Contrib::Decorator::CollectionRepresenter

  property :per_page # Only works with will_paginate

  def page_url(args)
    songs_url args
  end
end
```

Roar-contrib provides you with the following methods defined on the Decorator instance that work with either `will_paginate` or `Kaminari`:
- `#current_page`
- `#next_page`
- `#previous_page`
- `#per_page`
- `#total_entries`

You can use them as properties by telling Roar to execute the methods in the context of the Decorator.

```ruby
class SongsRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::Contrib::Decorator::PageRepresenter
  include Roar::Contrib::Decorator::CollectionRepresenter

  property :per_page, :exec_context => :decorator # Works with either will_paginate or Kaminari

  def page_url(args)
    songs_url args
  end
end
```

## Contributing
Contributions welcome!! :smile:

1. Fork it ( https://github.com/sweatshirtio/roar-contrib/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
