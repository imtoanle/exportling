require 'spec_helper'

describe Exportling::Exporter::AssociationDetails do
  let(:association_details) { HouseCsvExporter.associations[:rooms] }
  let(:callback_options)    { { on_entry: 'on_room', on_finished: 'on_rooms_finished' } }
  let(:exporter_class)      { RoomExporter }

  describe '.initialize' do
    describe 'sets' do
      describe 'callback_options' do
        subject { association_details.callbacks }
        specify { expect(subject).to eq(callback_options) }
      end
      describe 'exporter_class' do
        subject { association_details.exporter_class }
        specify { expect(subject).to eq(exporter_class) }
      end
      describe 'params' do
        subject { association_details.params }
        specify { expect(subject).to be_a(Exportling::Exporter::AssociationParams) }
      end
    end
  end

  describe '#child_options' do
    let(:context_object)     { double('House', id: 123) }

    subject { association_details.child_options(context_object) }
    specify { expect(subject).to be_a(Hash) }
    describe ':as' do
      subject { association_details.child_options(context_object)[:as] }
      specify { expect(subject).to eq(:child) }
    end

    describe ':callbacks' do
      subject { association_details.child_options(context_object)[:callbacks] }
      specify { expect(subject).to eq(callback_options) }
    end

    describe ':params' do
      let(:association_params) { association_details.params }
      let(:replaced_params)    { { house_id: 123 } }
      before do
        allow(association_params).to receive(:replaced_params).with(context_object) { replaced_params }
      end

      subject { association_details.child_options(context_object)[:params] }
      specify { expect(subject).to eq(replaced_params) }
    end
  end
end
