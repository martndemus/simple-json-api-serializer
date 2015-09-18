# Simple JSONApi::Serializer

* An extremely simple JSON Api serializer.
* It supports serializing any Ruby object. 
* It does not target a specific framework.
* Does not (yet) support links and includes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple-json-api-serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple-json-api-serializer

## Usage

You can use the JSONApi::Serializer in two ways:
* In a DSL like manner by declaring your configuration in as subclass of `JSONApi::ObjectSerializerDefinition`
* By using `JSONApi::Serializer#to_json` directly with an object and a configuration hash

### The DSL way

The simplest serializer you can declare looks like this:

```ruby
class MyObjectSerializer < JSONApi::ObjectSerializerDefinition
end
```

You can then serialize objects with it:

```ruby
MyObject = Struct.new(:id)
my_object = MyObject.new(1)

MyObjectSerializer.serialize(my_object)
```

Which generates:

```json
{
  "data": {
    "type": "my-objects",
    "id": "1"
  }
}
```

#### Configuring the output

```ruby
class PersonSerializer < JSONApi::ObjectSerializerDefinition
  id_attribute :ssn
  
  attributes :first_name, :last_name
end

Person = Struct.new(:ssn, :first_name, :last_name)
joe = Person.new('X3DAB4CFJ0', 'Joe', 'Strummer')

PersonSerializer.serialize(joe)
```

Generates:

```json
{
  "data": {
    "type": "persons",
    "id": "X3DAB4CFJ0",
    "attributes": {
      "first-name": "Joe",
      "last-name":  "Strummer"
    }
  }
}
```

#### Adding relationships

```ruby
class PostSerializer < JSONApi::ObjectSerializerDefinition
  attributes :title, :content
  
  has_one  :author
  has_many :comments
end

Post = Struct.new(:id, :title, :content, :author, :comments) do
  def author_id
    author.id
  end
  
  def comment_ids
    comments.map(&:id)
  end
end

post = Post.new(1, "How to serialize objects", "...", author, comments)

PostSerializer.serialize(post)
```

Generates:

```json
{
  "data": {
    "type": "posts",
    "id": "1",
    "attributes": {
      "title": "How to serialize objects",
      "content": "...",
    },
    "relationships": {
      "author": {
        "data": { "type": "authors", "id": "42" },
      },
      "comments": {
        "data": [
          { "type": "comments", "id": "1" },
          { "type": "comments", "id": "2" }
        ]
      }
    }
  }
}
```

If your object does not abide by the `_id` or `_ids` convention for relations,
you can specify what method should be called to retrieve the foreign key with
`has_one  :author, foreign_key: :username`

You can also specify the type of the related object with: `has_one :author, type: :user`.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/martndemus/simple-json-api-serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
