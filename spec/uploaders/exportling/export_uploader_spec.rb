require 'spec_helper'

describe Exportling::ExportUploader do
  before do
    Exportling::ExportUploader.enable_processing = true
    allow(Exportling).to receive(:base_storage_directory) { 'test_export_dir' }
  end

  let(:owner) { create(:user) }
  let(:export) { create(:export, owner: owner) }
  let(:uploader) { Exportling::ExportUploader.new(export, :output) }
  let(:expected_base_dir) { "#{Rails.root}/test_export_dir" }

  describe '#directory_name' do
    context 'Exportling.s3_bucket_name is a block' do
      around(:each) do |example|
        s3_bucket_name =Exportling.s3_bucket_name
        Exportling.s3_bucket_name = -> { 'some-dir' }
        example.run
        Exportling.s3_bucket_name = s3_bucket_name
      end
      specify { expect(uploader.directory_name).to eq 'some-dir' }
    end

    context 'Exportling.s3_bucket_name is a string' do
      around(:each) do |example|
        s3_bucket_name =Exportling.s3_bucket_name
        Exportling.s3_bucket_name = 'test-fog-directory'
        example.run
        Exportling.s3_bucket_name = s3_bucket_name
      end
      specify { expect(uploader.directory_name).to eq 'test-fog-directory' }
    end

  end

  describe '#store_dir' do
    specify { expect(uploader.store_dir).to eq "exports/#{owner.id}" }
  end

  describe '#cache_dir' do
    specify { expect(uploader.cache_dir).to eq "#{Rails.root}/tmp/exportling/exports/#{owner.id}" }
  end
end

