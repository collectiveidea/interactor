# frozen_string_literal: true

# What are 'Too Simple' Actions?
#
# These actions are useful to see how basic actions can be created,
# but there is a strong argument to suggest that these should really
# be a methods on some existing class due to the fact that it is not
# complicated enough to be a service object or (SRP action).
#
# For more information, see the sinful iterator
# https://ian-alexander.medium.com/clean-architecture-and-the-sinful-interactor-e50f5d5584bd
describe TooSimple::FullNameAction do
  subject { call }

  let(:call) { described_class.call(**params) }

  context 'with valid data' do
    subject { call.full_name }

    context 'with first_name' do
      let(:params) { { first_name: 'David' } }

      context 'context values' do
        it { is_expected.to eq('David')}
      end
    end

    context 'with last_name' do
      let(:params) { { last_name: 'Cruwys' } }

      context 'context values' do
        it { is_expected.to eq('Cruwys')}
      end
    end

    context 'with first_name and last_name' do
      let(:params) { { first_name: 'David', last_name: 'Cruwys' } }

      context 'context values' do
        it { is_expected.to eq('David Cruwys')}
      end
    end
  end

  context 'with invalid data' do
    subject { call.failure? }

    context 'missing first_name, last_name' do
      let(:params) { { } }

      it { is_expected.to be_falsey}
    end
  end

  describe 'example' do
    fit 'good data' do
      result = TooSimple::FullNameAction.call(first_name: 'David', last_name: 'Cruwys')

      puts "first_name: #{result.first_name}"
      puts "last_name: #{result.last_name}"
      puts "full_name: #{result.full_name}"
    end

    it 'bad data' do
      result = TooSimple::FullNameAction.call()

      puts "first_name: #{result.first_name}"
      puts "last_name: #{result.last_name}"
      puts "full_name: #{result.full_name}"
      puts "message: #{result.message}"
      puts "success?: #{result.success?}"
      puts "failure?: #{result.failure?}"
    end
  end
end
