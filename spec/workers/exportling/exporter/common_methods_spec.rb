require 'spec_helper'

describe Exportling::Exporter::CommonMethods do
  let(:exporter)        { HouseCsvExporter.new }
  let(:house)           { create(:house) }
  let(:attr_keys)       { %w(id price square_meters) }

  describe 'to_required_attributes_hash' do
    subject { exporter.to_required_attributes_hash(house) }
    specify { expect(subject).to be_a Hash }
    specify { expect(subject.keys).to match_array attr_keys }
  end
end
