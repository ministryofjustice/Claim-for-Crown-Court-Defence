require 'rails_helper'

describe ErrorDetailCollection do

  let(:edc)         { ErrorDetailCollection.new }

  context 'assign a single values to a key' do
    it 'should make an array containing the single object' do
      edc[:key1] = 'value for key 1'
      expect(edc[:key1]).to eq( ['value for key 1'] )
    end
  end


  context 'assign multiple values to a key' do
    it 'should make an array containing all the objects assigned' do
      edc[:key1] = 'value for key 1'
      edc[:key1] = 'second value for key 1'
      expect(edc[:key1]).to eq( ['value for key 1', 'second value for key 1'] )
    end
  end

 
  describe 'short_messagas_for' do
    context 'one short_message per key' do
      it 'should return the short message for the named key' do
        edc[:dob] = ErrorDetail.new(:dob, 'Date of birth is invalid', 'Invalid date')
        expect(edc.short_messages_for(:dob)).to eq 'Invalid date'
      end
    end

    context 'multiple short messages per key' do
      it 'should return a comma separated lit of messages for the named key' do
        edc[:dob] = ErrorDetail.new(:dob, 'Date of birth is invalid', 'Invalid date')
        edc[:dob] = ErrorDetail.new(:dob, 'Date of birth too far in the past', 'Too old')
        expect(edc.short_messages_for(:dob)).to eq 'Invalid date, Too old'
      end
    end
  end


  describe 'header_errors' do
    it 'should return an array of arrays containing feildname and long message for each error' do
      edc[:first_name] = ErrorDetail.new(:first_name, 'You must specify a first name', 'Cannot be blank')
      edc[:dob] = ErrorDetail.new(:dob, 'Date of birth is invalid', 'Invalid date')
      edc[:dob] = ErrorDetail.new(:dob, 'Date of birth too far in the past', 'Too old')

      expect(edc.header_errors.size).to eq 3
      expect(edc.header_errors).to eq(
        [
          ErrorDetail.new(:first_name, 'You must specify a first name', 'Cannot be blank'),
          ErrorDetail.new(:dob, 'Date of birth is invalid', 'Invalid date'),
          ErrorDetail.new(:dob, 'Date of birth too far in the past', 'Too old')
        ]
      )
    end
  end

  describe 'size' do
    context 'empty collection' do
      it 'should return zero' do
        expect(edc.size).to eq 0
      end
    end

    context 'several fieldnames, one error per fieldname' do
      it 'should return the number of errors' do
        edc[:first_name] = ErrorDetail.new(:first_name, 'You must specify a first name', 'Cannot be blank')
        edc[:dob] = ErrorDetail.new(:dob, 'Date of birth is invalid', 'Invalid date')
        expect(edc.size).to eq 2
      end
    end
    
    context 'several fieldnames, some with multiple errors' do
      it 'should return the total number of errors' do
        edc[:first_name] = ErrorDetail.new(:first_name, 'You must specify a first name', 'Cannot be blank')
        edc[:dob] = ErrorDetail.new(:dob, 'Date of birth is invalid', 'Invalid date')
        edc[:dob] = ErrorDetail.new(:dob, 'Date of birth too far in the past', 'Too old')
        expect(edc.size).to eq 3
      end
    end

  end



end