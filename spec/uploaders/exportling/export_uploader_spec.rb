require 'spec_helper'

describe Exportling::ExportUploader do
  before do
    Exportling::ExportUploader.enable_processing = true
    allow(Exportling).to receive(:base_storage_directory) { 'test_export_dir' }
  end

  let(:owner)             { create(:user) }
  let(:export)            { create(:export, owner: owner) }
  let(:uploader)          { Exportling::ExportUploader.new(export, :output) }
  let(:expected_base_dir) { "#{Rails.root}/test_export_dir" }

  describe '#base_dir' do
    specify { expect(uploader.base_dir).to eq expected_base_dir }
  end

  describe '#store_dir' do
    specify { expect(uploader.store_dir).to eq "#{expected_base_dir}/exports/#{owner.id}" }
  end

  describe '#cache_dir' do
    specify { expect(uploader.cache_dir).to eq "#{expected_base_dir}/tmp/exports/#{owner.id}" }
  end
end
