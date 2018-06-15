class SupplierNumberCollectionPresenter < BasePresenter
  include Enumerable
  extend Forwardable
  def_delegators :mapped_supplier_numbers, :each

  presents :supplier_numbers

  private

  def mapped_supplier_numbers
    supplier_numbers.map { |sn| SupplierNumberPresenter.new(sn, view) }
  end
end
