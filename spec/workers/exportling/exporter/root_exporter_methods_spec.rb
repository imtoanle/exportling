require 'spec_helper'

describe Exportling::Exporter::RootExporterMethods do
  let(:exporter_class)  { HouseExporter }
  let(:exporter)        { exporter_class.new }
  let(:export)          { create(:export, klass: exporter_class.to_s, status: 'created') }

  before do
    exporter.instance_variable_set(:@export, export)
  end

  it_should_behave_like :performed_export, 'root', HouseExporter

  describe '#perform_as_root' do
    subject { exporter.perform_as_root }

    describe 'temp file' do
      # Set the instance variable before running the test, so it will be initially set,
      # regardless of whether it is created by the perform method
      before  { exporter.instance_variable_set(:@temp_export_file, 'not nil') }
      subject { exporter.instance_variable_get(:@temp_export_file) }

      context 'when export successful' do
        it 'is deleted' do
          exporter.perform_as_root
          expect(subject).to be_nil
        end
      end

      context 'when export fails' do
        # simulate export failure
        before { allow(exporter).to receive(:finish_export).and_raise(StandardError) }

        it 'is deleted' do
          exporter.perform_as_root
          expect(subject).to be_nil
        end
      end
    end
  end

  describe 'finish_root_export' do
    subject { exporter.finish_root_export }
    before  { allow(exporter).to receive(:on_finish) }
    describe 'export status' do
      context 'when successful' do
        specify do
          expect { subject }.to change { export.reload.status }.to('completed')
        end
      end

      context 'when unsuccessful' do
        before { allow(export).to receive(:save) { false } }

        specify do
          subject
          expect(export.reload.status).to_not eq('completed')
        end
      end
    end

  end
end
