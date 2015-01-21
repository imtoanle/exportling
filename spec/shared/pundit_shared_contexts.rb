require 'spec_helper'

shared_context :using_pundit do
  before do
    allow_any_instance_of(described_class).to receive(:using_pundit) { true }
  end
end

shared_context :not_using_pundit do
  before do
    allow_any_instance_of(described_class).to receive(:using_pundit) { false }
  end
end
