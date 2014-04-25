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

    subject { exporter.perform(export.id, options) }

    context 'export already completed' do
      let(:options) { {} }
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
        let(:options) { {} }
        it 'performs the export as a root exporter' do
          expect(exporter).to receive(:perform_as_root)
          subject
        end
      end

      context 'with options' do
        context 'for child export' do
          let(:options) { { as: :child } }
          it 'peforms the export as a child exporter' do
            expect(exporter).to receive(:perform_as_child)
            subject
          end
        end
      end
    end
  end

  describe '#find_each' do
    let(:exporter)          { HouseExporter.new }
    let(:query_class_name)  { exporter.query_class_name }
    let(:query_class)       { query_class_name.constantize }

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
      let(:query_class)     { exporter.query_class_name.constantize }

      it 'passes merged params to the query object' do
        expect(query_class).to receive(:new).with(merged_params) { double('QueryObject', find_each: nil ) }
        exporter.perform(export.id, options)
      end
    end
  end

  describe '#query_params' do
    let(:export)                { create(:export, params: export_params) }
    let(:exporter)              { HouseExporter.new }

    before  { exporter.perform(export, params: options_params) }
    subject { exporter.query_params }
    context 'export.params empty' do
      let(:export_params) { {} }
      context 'options[:params] empty' do
        let(:options_params) { {} }
        specify { expect(subject).to eq({}) }
      end

      context 'options[:params] populated' do
        let(:options_params) { { foo: { id: 123 } } }
        it 'returns options[:params]' do
          expect(subject).to eq(options_params)
        end
      end
    end

    context 'export.params populated' do
      let(:export_params) { { foo: { bar: :baz } } }

      context 'options[:params] empty' do
        let(:options_params) { {} }
        it 'returns export.params' do
          expect(subject).to eq(export_params)
        end
      end

      context 'options[:params] populated' do
        context 'without param collisions' do
          let(:options_params) { { foo: { id: 123 } } }
          it 'merges params from both' do
            expect(subject).to eq(foo: { id: 123, bar: :baz })
          end
        end

        context 'with param collisions' do
          let(:options_params) { { foo: { bar: :qux } } }
          it 'gives options[:params] precidence' do
            expect(subject).to eq(foo: { bar: :qux })
          end
        end
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

  describe '#save_entry' do
    let(:exporter) { HouseExporter.new }
    let(:entry)    { double('Export Data') }

    subject { exporter.save_entry(entry) }

    describe 'default behaviour' do
      it 'inits @default_entries' do
        subject
        expect(exporter.instance_variable_get(:@export_entries)).to be_a(Array)
      end

      it 'saves the entry to @default_entries' do
        subject
        expect(exporter.instance_variable_get(:@export_entries)).to include(entry)
      end
    end
  end
end
