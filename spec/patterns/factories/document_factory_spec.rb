# frozen_string_literal: true

describe Factories::DocumentFactory do
  context 'with valid data' do
    subject { described_class.instance(**params).tap(&:transform) }

    let(:data) { { a: 'a', b: 'b', array: [{a: 'a1', b: 'b1'}, {a: 'a2', b: 'b2'}]} }
    let(:output) { data }

    context 'when no type' do
      let(:params) { { data: data } }

      it { is_expected.to be_a(Factories::Document).and have_attributes(data: data, output: output)}
    end

    context 'when type: :json' do
      let(:params) { { type: :json, data: data } }
      let(:output) { '{"a":"a","b":"b","array":[{"a":"a1","b":"b1"},{"a":"a2","b":"b2"}]}' }

      it { is_expected.to be_a(Factories::DocumentJson).and have_attributes(data: data, output: output)}
    end

    context 'when type: :xml' do
      let(:params) { { type: :xml, data: data } }
      let(:output) { '<root><a>a</a><b>b</b><array><a>a1</a><b>b1</b></array><array><a>a2</a><b>b2</b></array></root>' }

      it { is_expected.to be_a(Factories::DocumentXml).and have_attributes(data: data, output: output)}
    end
  end

  context 'with invalid data' do
    describe 'instance' do
      subject { described_class.instance(**params) }

      context 'when no params' do
        let(:params) { { } }

        it { is_expected.to be_nil }
      end
    end

    describe 'instance!' do
      subject { described_class.instance!(**params) }

      context 'when no params' do
        let(:params) { { } }

        it { expect { subject }.to raise_error(Interactor::Failure) }
      end
    end

    describe 'instance_as_context' do
      subject { described_class.instance_as_context(**params) }

      context 'when no params' do
        let(:params) { { } }

        it { is_expected.to be_a(Interactor::Context).and have_attributes(message: 'Command failed') }
      end
    end
  end
end
