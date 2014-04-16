require 'spec_helper'

describe Exportling::Exporter::ChildExporterMethods do

  let(:exporter_class)  { RoomExporter }
  let(:exporter)        { exporter_class.new }
  let(:export)          { create(:export, klass: exporter_class.to_s, status: 'created') }


  it_should_behave_like :performed_export, 'child', RoomExporter

  describe '#perform_as_child' do
    before { exporter.instance_variable_set(:@export, export) }
    it_should_behave_like :performed_export, 'child', RoomExporter

    subject { exporter.perform_as_child }
    it 'does not create a new file' do
      expect(Tempfile).to receive(:new).never
      subject
    end

    it 'does not complete the export' do
      expect(export).to receive(:complete).never
      subject
    end
  end
end
