module Interactor
  class Registry

    attr_reader :namespaces

    def initialize(namespaces = [])
      @namespaces = namespaces
    end

    def method_missing(symbol, *args)
      interactor = build_interactor(symbol)
      if interactor.respond_to?(:perform)
        interactor.perform(*args)
      else
        self.class.new(namespaces + [symbol])
      end
    rescue NameError
      super
    end

    def respond_to_missing?(symbol, include_private = false)
      !build_interactor(symbol).nil?
    rescue NameError
      super
    end

    def build_interactor(name)
      name = [namespaces, name].flatten.join('/')
      constantize(camelize(name))
    end

    protected

    def camelize(term)
      term.to_s.gsub(/([a-z\d]*)/i) { $1.capitalize }.
        gsub('/', '::').gsub('_', '')
    end

    def constantize(class_name)
      Kernel.const_get class_name
    end

  end
end
