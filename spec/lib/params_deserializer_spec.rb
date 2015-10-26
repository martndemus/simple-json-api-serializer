require 'spec_helper'

RSpec.describe JSONApi::ParamsDeserializer, '#deserialize' do
  it "deserializes attributes" do
    params = {
      'type' => 'foos',
      'id'   => '1',
      'attributes' => {
        'foo' => 1,
        'bar' => 'baz'
      }
    }

    result = subject.deserialize(params)
    expect(result).to eq({ 'foo' => { 'id' => '1', 'foo' => 1, 'bar' => 'baz' } })
  end

  it "deserializes without root key" do
    params = {
      'type' => 'foos',
      'attributes' => {
        'foo' => 1,
        'bar' => 'baz'
      }
    }

    result = subject.deserialize(params, root: false)
    expect(result).to eq({ 'foo' => 1, 'bar' => 'baz' })
  end

  it "deserializes relationships" do
    params = {
      'type' => 'foos',
      'relationships' => {
        'bar' => {
          'data' => {
            'type' => 'bars',
            'id' => 42
          }
        }
      }
    }

    result = subject.deserialize(params)
    expect(result).to eq({ 'foo' => { 'bar_id' => 42, 'bar_type' => 'Bar' } })
  end

  it "doesn't trip over an empty relationship" do
    params = {
      'type' => 'foos',
      'relationships' => {
        'bar' => {
          'data' => nil
        }
      }
    }

    result = subject.deserialize(params)
    expect(result).to eq({ 'foo' => {} })
  end

  it "has an emptry attributes hash" do
    result = subject.deserialize({ 'type' => 'foos', 'attributes' => {} })
    expect(result).to eq({ 'foo' => {} })
  end

  it "normalizes keys" do
    params = {
      'type' => 'bar-foos',
      'attributes' => {
        'quux-baz' => 42
      },
      'relationships' => {
        'foo-bar' => {
          'data' => {
            'type' => 'bars',
            'id' => 42
          }
        }
      }
    }

    result = subject.deserialize(params)
    expect(result).to eq({
      'bar_foo' => {
        'quux_baz'     => 42,
        'foo_bar_id'   => 42,
        'foo_bar_type' => 'Bar'
      }
    })
  end
end
