require 'rails_helper'

describe JsonTemplate do

  it 'generates a json template' do
    result = JsonTemplate.generate
    expect {JSON.parse(result)}.to_not raise_error # parse will raise an exception is JSON is not valid
  end

  it 'contains placeholder values that are representative of the required data types' do
    result = JSON.parse(JsonTemplate.generate)
    typed_placeholders = ['string', 1, 1.1, true]
    get_vals(result)
    @values.each do |value|
      expect(typed_placeholders.include?(value)).to be true
    end
  end

  def get_vals(result)
    @values ||= []
    result.values.each do |value|
      if value.class == Hash
        get_vals(value)
      elsif value.class == Array
        get_vals(value[0])
      else
        @values << value
      end
    end
  end

  context 'contains keys that' do

    it 'relate to models' do
      result = JSON.parse(JsonTemplate.generate)
      result.each do |key, value|
        expect(key.singularize.camelize.constantize.superclass).to eq ActiveRecord::Base
      end
    end

    it 'are pluralised when pointing to an Array' do
      result = JSON.parse(JsonTemplate.generate)
      result.each do |key, value| 
        if key.pluralize ==  key # it's already plural therefore pluralize does nothing
          expect(value.class).to eq Array
        end
      end
    end

    it 'are singlar when pointing to a Hash' do
      result = JSON.parse(JsonTemplate.generate)
      result.each do |key, value| 
        if key.pluralize !=  key # the key is singular and is therefore pluralized
          expect(value.class).to eq Hash
        end
      end
    end

    it 'are lower case' do
      result = JSON.parse(JsonTemplate.generate)
      result.each do |key, value| 
        expect(key.downcase).to eq key # i.e. there is no change
      end
    end

    it 'are snake_case' do
      result = JSON.parse(JsonTemplate.generate)
      result.each do |key, value| 
        expect(key.underscore).to eq key # i.e. there is no change
      end
    end

  end

end
