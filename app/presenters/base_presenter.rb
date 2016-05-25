class BasePresenter < SimpleDelegator

  def initialize(model, view)
    @model, @view = model, view
    super(@model)
  end


  def self.presents(name)
    define_method(name) do
      @model
    end
  end

  private_class_method :presents

  private


  def h
    @view
  end
end
