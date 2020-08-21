describe Interactor::BaseInteractor do
  let(:mock_class) do
    Class.new do
      include Interactor

      requires :argument_1, :argument_2
    end
  end
  subject { mock_class.call(arguments) }

  context 'when passing all the correct arguments' do
    let(:arguments) { { argument_1: true, argument_2: false } }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'when passing arguments with nil value' do
    let(:arguments) { { argument_1: nil, argument_2: nil } }

    it 'does not raise an error' do
      expect { subject }.to_not raise_error
    end
  end

  context 'when missing an arguments' do
    let(:arguments) { { argument_1: true } }

    it 'raises an ArgumentError' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
