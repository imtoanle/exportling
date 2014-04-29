require 'spec_helper'

describe Exportling::Export do
  # This exporter is defined in the dummy app
  let(:exporter_class)  { HouseCsvExporter }
  let(:export)          { create(:export, klass: exporter_class.to_s, status: 'foo') }

  describe '#worker_class' do
    subject { export.worker_class }
    specify { expect(subject).to eq exporter_class }
  end

  describe '#completed?' do
    subject { export.completed? }
    before  { export.update_attributes(status: status) }
    context 'status is not "completed"' do
      let(:status) { 'created' }
      it { should eq false }
    end

    context 'status is "completed"' do
      let(:status) { 'completed' }
      it { should eq true }
    end
  end

  describe '#incomplete?' do
    before  { allow(export).to receive(:completed?) { completed } }
    subject { export.incomplete? }
    context 'when complete' do
      let(:completed) { true }
      specify { expect(subject).to eq false }
    end

    context 'when incomplete' do
      let(:completed) { false }
      specify { expect(subject).to eq true }
    end
  end

  describe '#processing?' do
    before  { export.status = export_status }
    subject { export.processing? }

    context 'when status is processing' do
      let(:export_status) { 'processing' }
      specify { expect(subject).to eq true }
    end

    context 'when status is not processing' do
      let(:export_status) { 'created' }
      specify { expect(subject).to eq false }
    end
  end

  describe 'file_name' do
    let(:created_time)        { Time.zone.parse('Feb 1, 2009') }
    let(:export_id)           { export.id }
    let(:expected_file_name)  { "#{export_id}_houses_2009-02-01.csv" }

    before  { export.update_column(:created_at, created_time) }
    specify { expect(export.file_name).to eq expected_file_name }
  end

  describe 'status changes' do
    subject { export.status }
    describe '#complete!' do
      before  { export.complete! }
      specify { expect(subject).to eq 'completed' }
    end

    describe '#fail!' do
      before  { export.fail! }
      specify { expect(subject).to eq 'failed' }
    end

    describe 'set_processing!' do
      before  { export.set_processing! }
      specify { expect(subject).to eq 'processing' }
    end

    describe '#perform!' do
      subject { export.perform! }
      it 'calls perform! on the worker class' do
        expect(export.worker_class).to receive(:perform).with(export.id)
        subject
      end
    end

    describe '#perform_async!' do
      Sidekiq::Testing.fake!
      subject { export.perform_async! }

      it 'queues its exporter for processing' do
        expect { subject }.to change(export.worker_class.jobs, :size).by(1)
      end
    end
  end

  describe 'Uploader' do
    let(:temp_export_file)      { Tempfile.new('test_export_file') }
    let(:temp_export_filename)  { File.basename(temp_export_file) }
    let(:expected_file_path) do
      "#{Rails.root}/#{Exportling.base_storage_directory}"\
      "/exports/#{export.owner_id}/#{temp_export_filename}"
    end

    before  { File.delete(expected_file_path) if File.exists?(expected_file_path) }
    after   { File.delete(expected_file_path) if File.exists?(expected_file_path) }

    describe '#output' do
      subject { export.output }
      context 'when no file added' do
        specify { expect(subject).to be_a(Exportling::ExportUploader) }
        specify { expect(subject.path).to be_nil }
        it 'does not create the file' do
          expect(File.exists?(expected_file_path)).to eq false
        end

      end

      context 'when file added' do
        before do
          export.output = temp_export_file
          export.save!
        end

        specify { expect(subject).to be_a(Exportling::ExportUploader) }
        specify { expect(subject.path).to eq expected_file_path }
        it 'creates the file' do
          expect(File.exists?(expected_file_path)).to eq true
        end
      end
    end
  end
end
