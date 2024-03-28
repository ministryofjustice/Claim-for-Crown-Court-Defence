module ExternalUsers
  class RepresentationOrder < BasePresenter
    presents :representation_order

    def maat_details
      { case_number: '???' }
    end
  end
end
