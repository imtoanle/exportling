require 'spec_helper'

describe Exportling::ExportDecorator do
  let(:owner)     { create :user }
  let(:export)    { create(:export, { owner: owner }) }
  let(:decorated_export) { export.decorate }

  describe '#download_path' do
    let(:file_name) { 'exported_file.csv' }
    let(:expected_path) { "/exportling/export/#{owner.id}/#{export.id}/#{file_name}" }

    before { allow(export).to receive(:file_name) { file_name } }

    specify { expect(decorated_export.download_path).to eq expected_path }
  end
end
