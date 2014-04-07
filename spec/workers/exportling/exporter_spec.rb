require 'spec_helper'

describe Exportling::Exporter do

  # TODO: Consider making a small class to inherit the specced exporter
  #         Alternatively, this class could be created in the dummy app (which is only for testing anyway)

  describe 'export fields' do
    subject { Exportling::Exporter.fields }

    context 'no fields have been set' do
      it { should be_empty }
    end
  end
end
