class DocType
  attr_reader :id, :sequence, :name

  def initialize(id, sequence, name)
    @id = id
    @sequence = sequence
    @name = name
  end

  DOCTYPES = [
    DocType.new(1,  500,  'Representation order'),
    DocType.new(2,  200,  'LAC1 - memo of conviction'),
    DocType.new(3,  300,  'Committal bundle front sheets'),
    DocType.new(4,  400,  'A copy of the indictment'),
    DocType.new(5,  100,  'Order in respect of judicial apportionment'),
    DocType.new(6,  800,  'Expenses invoices'),
    DocType.new(7,  600,  'Hardship supporting evidence'),
    DocType.new(8,  700,  'Details of previous fee advancements'),
    DocType.new(9, 1000,  'Justification for out of time claim'),
    DocType.new(10, 1100,  'Special preparation form'),
    DocType.new(11, 1200,  'Prior authority CRM4')
  ].sort_by(&:sequence)

  FEE_REFORM_DOC_TYPE_IDS = [1, 3, 4, 6].freeze

  def self.all
    DOCTYPES
  end

  def self.for_fee_reform
    DOCTYPES.select { |doc| FEE_REFORM_DOC_TYPE_IDS.include?(doc.id) }
  end

  def self.all_first_half
    DOCTYPES.slice(0, slice_size)
  end

  def self.all_second_half
    DOCTYPES.slice(slice_size, slice_size)
  end

  def self.slice_size
    (DOCTYPES.size + 1) / 2
  end

  # returns a single DocType given its id
  def self.find(id)
    doctype = DOCTYPES.detect { |dt| dt.id == id }
    raise ArgumentError, "No DocType with id #{id}" if doctype.nil?
    doctype
  end

  # returns a collection of DocTypes give a list or array of ids
  def self.find_by_ids(*ids)
    ids = ids.flatten
    DOCTYPES.select { |dt| ids.include?(dt.id) }
  end
end
