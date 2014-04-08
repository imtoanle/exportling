require 'spec_helper'

describe Exportling::Export do
  # This exporter is defined in the dummy app
  let(:exporter)  { HouseExporter }
  let(:export)    { create(:export, klass: exporter.to_s, status: 'foo') }

  describe '#worker' do
    subject { export.worker_class }
    specify { expect(subject).to eq exporter }
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
    let(:expected_file_name)  { "#{export_id}_HouseExporter_2009-02-01.csv" }

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
end
