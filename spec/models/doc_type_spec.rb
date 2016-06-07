require 'rails_helper'


describe DocType do
  describe '.find' do
    it 'should return a DocTypeInstance with the specified id' do
      dti = DocType.find(4)
      expect(dti.id).to eq 4
      expect(dti.name).to eq 'A copy of the indictment'
    end

    it 'should raise if no record with that id is found' do
      expect {
        DocType.find(888)
      }.to raise_error ArgumentError, "No DocType with id 888"
    end
  end


  describe '.find_by_ids' do
    it 'should return a list of matching ids in id order when ids given as a list' do
      doctypes = DocType.find_by_ids(5, 9, 1, 44)
      expect(doctypes.map(&:id)).to eq([5, 1, 9])
    end
    it 'should return a list of matching ids in sequence order when ids given as an array' do
      doctypes = DocType.find_by_ids([5, 9, 1, 44])
      expect(doctypes.map(&:id)).to eq([5, 1, 9])
    end
    it 'should return an empty array if no matching ids' do
      doctypes = DocType.find_by_ids(99, 188)
      expect(doctypes).to be_empty
    end
  end

  describe '.all_first_half'do
    it 'should return the first half of doctypes' do
      expected = DocType::DOCTYPES[0, 5]
      expect(DocType.all_first_half).to eq expected
    end
  end

  describe '.all_second_half'do
    it 'should return the first half of doctypes' do
      expected = DocType::DOCTYPES[5, 4]
      expect(DocType.all_second_half).to eq expected
    end
  end
end
