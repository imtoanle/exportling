require 'spec_helper'

describe Exportling::Exporter::AssociationParams do
  let(:association_options) { HouseExporter.associations[:rooms] }
  let(:params)              { association_options[:params] }
  let(:association_params)  { described_class.new(params) }

  describe '#replaced_params' do
    subject { association_params.replaced_params(context_object) }

    context 'given an object that responds to all symbols' do
      let(:context_object)  { double('House', id: 123) }
      let(:expected_params) { { house_id: 123 } }

      context "given a house with id, 123" do
        specify { expect(subject).to eq expected_params }
      end
    end
  end

  describe '#replace_param' do
    subject { association_params.replace_param(context_object, param_symbol) }
    context 'given a context object' do
      let(:context_object) { double('House', id: 123) }

      context 'that responds to param_symbol' do
        let(:param_symbol) { :id }
        specify { expect(subject).to eq(123) }
      end

      context 'that does not respond to param_symbol' do
        let(:param_symbol) { :foo }
        specify { expect{subject}.to raise_error(ArgumentError) }
      end
    end
  end
end
