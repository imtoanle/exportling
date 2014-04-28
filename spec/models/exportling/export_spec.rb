require 'spec_helper'

describe Exportling::Export do
  # This exporter is defined in the dummy app
  let(:exporter_class)  { HouseCsvExporter }
  let(:export)          { create(:export, klass: exporter_class.to_s, status: 'foo') }

  describe '#worker_class' do
    subject { export.worker_class }
    specify { expect(subject).to eq exporter_class }
  end

  describe 'completed?' do
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

  describe 'file_name' do
    let(:created_time)        { Time.zone.parse('Feb 1, 2009') }
    let(:export_id)           { export.id }
    let(:expected_file_name)  { "#{export_id}_HouseCsvExporter_2009-02-01.csv" }

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
