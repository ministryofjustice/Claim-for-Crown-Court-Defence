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
    DocType.new(3,  300,  'Committal bundle front sheet(s)'),
    DocType.new(4,  400,  'A copy of the indictment'),
    DocType.new(5,  100,  'Order in respect of judicial apportionment'),
    DocType.new(6,  800,  'Expenses invoices'),
    DocType.new(7,  700,  'Hardship supporting evidence'),
    DocType.new(8,  600,  'Details of previous fee advancements'),
    DocType.new(9, 1000,  'Justification for out of time claim'),
  ].sort{ |a, b|  a.sequence <=> b.sequence }

  def self.all
    DOCTYPES
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
    doctype = DOCTYPES.detect{ |dt| dt.id == id }
    raise ArgumentError.new("No DocType with id #{id}") if doctype.nil?
    doctype
  end


  # returns a collection of DocTypes give a list or array of ids
  def self.find_by_ids(*ids)
    ids = ids.flatten
    DOCTYPES.select{ |dt| ids.include?(dt.id) }
  end


end
