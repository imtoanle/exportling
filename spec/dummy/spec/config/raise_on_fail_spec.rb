require 'spec_helper'

describe 'Exportling Config' do
  let(:exporter_class)  { HouseCsvExporter }
  let(:exporter)        { exporter_class.new }
  let(:export) do
    create(:export, klass: exporter_class.to_s, status: 'created')
  end
  before  { allow(Exportling).to receive(:raise_on_fail) { raise_on_fail } }

  describe 'raise_on_fail' do
    shared_context :fail_export do
      before do
        exporter_class_inst = allow_any_instance_of(exporter_class)
        exporter_class_inst.to receive(:on_start).and_raise('an error!')
      end
    end

    subject { export.perform! }

    context 'when true' do
      let(:raise_on_fail) { true }

      context 'and export successful' do
        specify { expect { subject }.to_not raise_error }
      end

      context 'and export fails' do
        include_context :fail_export
        specify { expect { subject }.to raise_error(RuntimeError) }
      end
    end

    context 'when false' do
      let(:raise_on_fail) { false }
      context 'and export successful' do
        specify { expect { subject }.to_not raise_error }
      end

      context 'and export fails' do
        include_context :fail_export
        specify { expect { subject }.to_not raise_error }
      end
    end
  end
end
