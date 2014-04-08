require 'spec_helper'

describe Exportling::Exporter do

  describe '.fields' do
    context 'no fields have been set' do
      specify { expect(Exportling::Exporter.fields).to be_empty }
    end

    context 'fields have been set in the extending class' do
      specify { expect(HouseExporter.fields).to match_array [:id, :price, :square_meters] }
    end
  end

  describe '#fields' do
    context 'no fields have been set' do
      specify { expect(Exportling::Exporter.new.fields).to be_empty }
    end

    context 'fields have been set in the extending class' do
      specify { expect(HouseExporter.new.fields).to match_array HouseExporter.fields }
    end
  end

  describe '#field_names' do
    context 'no fields have been set' do
      specify { expect(Exportling::Exporter.new.field_names).to be_empty }
    end

    context 'fields have been set in the extending class' do
      specify { expect(HouseExporter.new.field_names).to match_array ['id', 'price', 'square_meters'] }
    end
  end

  describe '.query_object' do
    context 'not set' do
      specify { expect(Exportling::Exporter.query_object).to be_nil }
    end

    context 'set in extending class' do
      specify { expect(HouseExporter.query_object).to eq HouseExporterQuery }
    end
  end

  describe '#query_object' do
    context 'not set' do
      specify { expect(Exportling::Exporter.new.query_object).to be_nil }
    end

    context 'set in extending class' do
      specify { expect(HouseExporter.new.query_object).to eq HouseExporterQuery }
    end
  end

  describe '.perform' do
    let(:export_id) { 1 }
    it 'calls perform on its instance' do
      expect_any_instance_of(described_class).to receive(:perform).with(export_id).once
      described_class.perform(export_id)
    end
  end

  describe '#perform' do
    let(:exporter_class)  { HouseExporter }
    let(:exporter)        { exporter_class.new }
    let(:export)          { create(:export, klass: exporter_class.to_s, status: 'created') }

    subject { exporter.perform(export.id) }

    context 'export already completed' do
      before { export.complete! }

      # Check that this displays the opposite behaviour of below (calls nothing)
      xit 'does nothing if the export is completed'
    end

    context 'export not completed' do
      it 'calls on_start callback once' do
        expect(exporter).to receive(:on_start).once
        subject
      end

      it 'calls on_start callback once' do
        expect(exporter).to receive(:on_finish).once
        subject
      end

      it 'calls on_entry callback once per entry' do
        allow(exporter).to receive(:find_each).and_yield(:foo).and_yield(:bar)
        expect(exporter).to receive(:on_entry).with(:foo).ordered
        expect(exporter).to receive(:on_entry).with(:bar).ordered
        subject
      end
    end
  end

  describe '#find_each' do
    let(:exporter)     { HouseExporter.new }
    let(:query_object) { exporter.query_object }

    before { exporter.instance_variable_set(:@export, double('export', params: {})) }

    it 'calls #find_each of the query object' do
      expect_any_instance_of(query_object).to receive(:find_each)
      exporter.find_each{ |i| }
    end
  end

  describe 'abstract_methods' do
    it { should respond_to :on_start }
    it { should respond_to :on_finish }
    it { should respond_to :on_entry }

    describe '#on_entry' do
      specify { expect{ described_class.new.on_entry({}) }.to raise_error NotImplementedError }
    end
  end
end
