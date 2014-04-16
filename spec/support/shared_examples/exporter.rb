shared_examples :performed_export do |export_type, exporter_class|
  let(:exporter)        { exporter_class.new }
  let(:export)          { create(:export, klass: exporter_class.to_s, status: 'created') }
  let(:options)         { {} }

  # Returned by find_each
  let(:yield1) { double('find_each_result_1', id: 1, name: :foo) }
  let(:yield2) { double('find_each_result_2', id: 2, name: :foo) }

  before do
    options[:as] = :child if export_type == 'child'
  end

  subject { exporter.perform(export.id, options) }

  context 'when successful' do
    it 'calls on_start callback once' do
      expect(exporter).to receive(:on_start).once
      subject
    end

    it 'calls on_finish callback once' do
      expect(exporter).to receive(:on_finish).once
      subject
    end

    it 'calls on_entry callback once per entry' do
      allow(exporter).to receive(:associated_data_for)
      allow(exporter).to receive(:find_each).and_yield(yield1).and_yield(yield2)
      expect(exporter).to receive(:on_entry).with(yield1, nil).ordered
      expect(exporter).to receive(:on_entry).with(yield2, nil).ordered
      subject
    end
  end

  describe 'when failed' do
    # simulate export failure
    let(:perform_method) { "perform_as_#{export_type}".to_sym }
    before { allow(exporter).to receive(perform_method).and_raise(StandardError) }

    specify do
      expect { subject }.to change{export.reload.status}.to('failed')
    end
  end
end
