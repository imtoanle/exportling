require 'spec_helper'

describe Exportling::ExporterDefaultQuery do
  class MockRelation; end

  class DefaultQueryNoneSet
    include Exportling::ExporterDefaultQuery
  end

  class DefaultQueryOptionKeySet
    include Exportling::ExporterDefaultQuery
    query_options_key :mock_key
  end

  class DefaultQueryKeyAndRelationSet
    include Exportling::ExporterDefaultQuery
    query_options_key :mock_key
    relation_class MockRelation
  end

  describe 'initial state validation' do
    shared_context :invalid_initial_state do
      it 'raises an error' do
        expect { subject }.to raise_error expected_error
      end
    end

    context 'when query_options_key blank' do
      subject { DefaultQueryNoneSet.new }
      let(:expected_error) do
        Exportling::ExporterDefaultQuery::KeyMissingError
      end

      it_behaves_like :invalid_initial_state
    end

    context 'when query_options_key provided' do
      context 'but relation_class blank' do
        subject { DefaultQueryOptionKeySet.new }
        let(:expected_error) do
          Exportling::ExporterDefaultQuery::RelationMissingError
        end

        it_behaves_like :invalid_initial_state
      end

      context 'and relation_class provided' do
        subject { DefaultQueryKeyAndRelationSet.new }
        it 'does not raise an error' do
          expect { subject }.to_not raise_error
        end
      end
    end
  end
end
