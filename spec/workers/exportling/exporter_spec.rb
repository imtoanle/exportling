require 'spec_helper'

describe Exportling::Exporter do

  describe 'abstract_methods' do
    specify { expect(described_class).to define_abstract_method :on_start }
    specify { expect(described_class).to define_abstract_method :on_entry }
    specify { expect(described_class).to define_abstract_method :on_finish }
  end

  describe '.perform' do
    let(:export_id) { 1 }
    it 'calls perform on its instance' do
      expect_any_instance_of(described_class).to receive(:perform).with(export_id, {}).once
      described_class.perform(export_id)
    end
  end

  describe '#perform' do
    let(:exporter_class)  { HouseExporter }
    let(:exporter)        { exporter_class.new }
    let(:export)          { create(:export, klass: exporter_class.to_s, status: 'created') }
    let(:options)         { {} }

    subject { exporter.perform(export.id, options) }

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
      context 'for root export' do
        it 'performs the export as a root exporter' do
          expect(exporter).to receive(:perform_as_root)
          subject
        end
      end

      context 'with options' do
        context 'for child export' do
          before { options[:as] = :child }
          it 'peforms the export as a child exporter' do
            expect(exporter).to receive(:perform_as_child)
            subject
          end
        end


      end
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

    context 'given query params' do
      let(:options)         { { params: { room: { house_id: 123 } } } }
      let(:export_params)   { { house: { id: 1 }, room: { name: %w(Bedroom Bathroom) } } }
      let(:merged_params)   { { house: { id: 1 }, room: { name: %w(Bedroom Bathroom), house_id: 123 } } }
      let(:exporter_class)  { RoomExporter }
      let(:exporter)        { exporter_class.new }
      let(:export)          { create(:export, klass: exporter_class.to_s, params: export_params) }
      let(:query_class)     { exporter.query_class }

      before do
        exporter.instance_variable_set(:@export, export)
        exporter.instance_variable_set(:@options, options)
      end

      it 'passes merged params to the query object' do
        expect(query_class).to receive(:new).with(merged_params) { double('QueryObject', find_each: nil ) }
        exporter.find_each { |i| }
      end
    end
  end

  describe '#associated_data_for' do
    let(:context_object)        { double('house', id: 123) }
    let(:export)                { create(:export, params: { house: { id: context_object.id } }) }
    let(:exporter)              { HouseExporter.new }
    let(:room_assoc)            { exporter.associations[:rooms] }
    let(:child_exporter_class)  { room_assoc.exporter_class }
    let(:child_options)         { room_assoc.child_options(context_object) }
    let(:room)                  { double('Room') }

    subject { exporter.associated_data_for(context_object) }
    before do
      exporter.instance_variable_set(:@export, export)
      expect_any_instance_of(child_exporter_class).to receive(:perform).with(export.id, child_options)
      allow_any_instance_of(child_exporter_class).to receive(:export_entries) { [room] }
    end

    it 'returns the associated export data' do
      expect(subject).to eq(rooms: [room])
    end
  end
end
