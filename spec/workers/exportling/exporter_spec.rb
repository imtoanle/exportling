require 'spec_helper'

describe Exportling::Exporter do

  describe 'abstract_methods' do
    specify { expect(described_class).to define_abstract_method :on_start }
    specify { expect(described_class).to define_abstract_method :on_entry }
    specify { expect(described_class).to define_abstract_method :on_finish }
  end

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

  describe '.query_class' do
    context 'not set' do
      specify { expect(Exportling::Exporter.query_class).to be_nil }
    end

    context 'set in extending class' do
      specify { expect(HouseExporter.query_class).to eq HouseExporterQuery }
    end
  end

  describe '#query_class' do
    context 'not set' do
      specify { expect(Exportling::Exporter.new.query_class).to be_nil }
    end

    context 'set in extending class' do
      specify { expect(HouseExporter.new.query_class).to eq HouseExporterQuery }
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

      it 'does nothing' do
        expect(exporter).to receive(:on_start).never
        expect(exporter).to receive(:on_finish).never
        expect(exporter).to receive(:on_entry).never
        subject
      end
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

    describe 'export' do
      context 'successful' do
        xit 'markes the export as completed'
      end
      context 'failed' do
        xit 'marks the export as failed'
      end
    end

    describe 'temp file' do
      xit 'is always deleted' # Even on raise during export process
    end
  end

  describe '#find_each' do
    let(:exporter)     { HouseExporter.new }
    let(:query_class) { exporter.query_class }

    before { exporter.instance_variable_set(:@export, double('export', params: {})) }

    it 'calls #find_each of the query object' do
      expect_any_instance_of(query_class).to receive(:find_each)
      exporter.find_each{ |i| }
    end
  end
end
