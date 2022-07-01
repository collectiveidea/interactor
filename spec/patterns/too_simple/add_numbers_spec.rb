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
describe TooSimple::AddNumbers do
  subject { call }

  let(:call) { described_class.call(**params) }

  context 'with valid data' do
    let(:params) { { lhs: 3, rhs: 6 } }

    context 'context values' do
      it { is_expected.to have_attributes(lhs: 3, rhs: 6, sum: 9)}
    end

    context '.failure?' do
      subject { call.failure? }

      it { is_expected.to be_falsey }
    end

    context '.success?' do
      subject { call.success? }

      it { is_expected.to be_truthy }
    end
  end

  context 'with invalid data' do
    let(:params) { { lhs: 3 } }

    context 'context values' do
      it { is_expected.to have_attributes(lhs: 3, message: 'Command failed')}
      it { is_expected.not_to respond_to(:rhs, :sum)}
    end

    context '.failure?' do
      subject { call.failure? }

      it { is_expected.to be_truthy }
    end
  end

  describe 'example' do
    it 'good data' do
      result = TooSimple::AddNumbers.call(lhs: 20, rhs: 30)

      puts "lhs: #{result.lhs}"
      puts "rhs: #{result.rhs}"
      puts "sum: #{result.sum}"
    end

    it 'bad data' do
      result = TooSimple::AddNumbers.call(lhs: 20)

      puts "lhs: #{result.lhs}"
      puts "rhs: #{result.rhs}"
      puts "sum: #{result.sum}"
      puts "message: #{result.message}"
      puts "success?: #{result.success?}"
      puts "failure?: #{result.failure?}"
    end
  end
end
