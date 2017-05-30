module DocTypes
  extend ActiveSupport::Concern

  private

  def set_doctypes
    @doc_types = DocType.all
  end
end
