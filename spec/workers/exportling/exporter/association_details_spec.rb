require 'spec_helper'

describe Exportling::Exporter::AssociationDetails do
  let(:association_options) { HouseExporter.associations[:rooms] }
  let(:callback_options)    { association_options[:callbacks] }
  let(:exporter_class)      { association_options[:exporter_class] }
  let(:association_details) { described_class.new(association_options) }

  describe '.initialize' do
    describe 'sets' do
      describe 'callback_options' do
        subject { association_details.callbacks }
        specify { expect(subject).to eq(callback_options) }
      end
      describe 'exporter_class' do
        subject { association_details.exporter_class }
        specify { expect(subject).to eq(exporter_class) }
      end
      describe 'params' do
        subject { association_details.params }
        specify { expect(subject).to be_a(Exportling::Exporter::AssociationParams) }
      end
    end
  end
end
