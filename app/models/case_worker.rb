# == Schema Information
#
# Table name: case_workers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  location_id :integer
#  days_worked :string
#  roles       :string
#

class CaseWorker < ActiveRecord::Base
  auto_strip_attributes squish: true, nullify: true

  ROLES = %w{ admin case_worker }

  include Roles

  serialize :days_worked, Array

  belongs_to :location
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  has_many :case_worker_claims, dependent: :destroy
  has_many :claims, class_name: Claim::BaseClaim, through: :case_worker_claims, after_remove: :unallocate!

  default_scope { includes(:user) }

  validates :location, presence: {message: 'Location cannot be blank'}
  validates :user, presence: {message: 'User cannot be blank'}
  validate  :days_worked_valid

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user


  def method_missing(method, *args)
    if method.to_s =~ /^days_worked_(.)$/
      self.days_worked[$1.to_i]
    elsif method.to_s =~/^days_worked_(.)=$/
      self.days_worked[$1.to_i]= args.first.to_i
    else
      super
    end
  end

  protected

  def unallocate!(record)
    record.submit! if record.allocated? && (record.case_workers - [self]).none?
  end


  private

  def days_worked_valid
    unless days_worked_size? && days_worked_valid_class_and_values?
      errors[:base] << 'Days worked invalid'
    end
    unless at_least_one_day_specified_as_working?
      errors[:base] << 'At least one day must be specified as a working day'
    end
  end

  def at_least_one_day_specified_as_working?
    self.days_worked.uniq != [ 0 ]
  end

  def days_worked_size?
    self.days_worked.size == 5
  end

  def days_worked_valid_class_and_values?
    self.days_worked.map(&:class).uniq == [ Fixnum ] && days_worked_valid_values?
  end

  def days_worked_valid_values?
    uniqs = self.days_worked.uniq.sort
    uniqs == [1] || uniqs == [0, 1] || uniqs == [0]
  end
end
