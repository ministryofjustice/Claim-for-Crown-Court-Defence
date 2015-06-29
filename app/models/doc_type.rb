class DocType

  attr_reader :id, :sequence, :name

  def initialize(id, sequence, name)
    @id = id
    @sequence = sequence
    @name = name
  end


  DOCTYPES = [
    DocType.new(1,  100,  'Representation Order'),
    DocType.new(2,  200,  'LAC1 - memo of conviction'),
    DocType.new(3,  300,  'The front sheet(s) from the commital bundle'),
    DocType.new(4,  400,  'A copy of the indictment'),
    DocType.new(5,  500,  'Order in respect of Judicial appointment'),
    DocType.new(6,  600,  'Invoices/receipts for accomodation and travel expenses'),
    DocType.new(7,  700,  'Hardship supporting evidence'),
    DocType.new(8,  700,  'Details of any and all fee advancements made previously'),
    DocType.new(9,  900,  'Other supporting evidence/misc. A list of acceptable evidence'),
    DocType.new(10, 1000, 'Written justification if claim submitted more than 3 months after case concludes'),
  ]

  def self.all
    DOCTYPES
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



