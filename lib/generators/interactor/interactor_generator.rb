require 'rails/generators/named_base'

module Interactor
  module Generators
    class InteractorGenerator < Rails::Generators::NamedBase
      desc 'This generator creates a new interactor in app/interactors'

      def create_interactor
        create_file "app/interactors/#{file_name}.rb", <<-FILE
class #{class_name}
  include Interactor

  before do

  end

  def call

  end

  after do

  end
end
        FILE
      end
    end
  end
end
