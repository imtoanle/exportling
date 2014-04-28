require 'spec_helper'

describe Exportling::ExportsController do
  # Use Exportling's routes
  routes { Exportling::Engine.routes }

  let(:current_user)    { create(:user) }
  let(:other_user)      { create(:user) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_export_owner) { current_user }
  end

  # Create test exports (one owned by the current user)
  let!(:export) { create(:export, owner: current_user) }
  let!(:other_export) { create(:export, owner: other_user) }

  describe 'GET #index' do
    before { get :index }

    it "renders the :index view" do
      expect(response).to render_template(:index)
    end

    it 'assigns exports for the current user' do
      expect(assigns(:exports)).to eq([export])
    end
  end

  shared_examples :export_from_valid_params do
    subject { assigns(:export) }

    it 'is assigned the params' do
      expect(subject.klass).to eq p_klass
      expect(subject.params).to eq p_params
      expect(subject.file_type).to eq p_file_type
    end

    it 'is assigned to the current owner' do
      expect(subject.owner).to eq(current_user)
    end
  end

  shared_context :invalid_export_params do
    let(:p_klass)             { nil }
    let(:p_file_type)         { nil }
    let(:mock_error_message)  { 'Export Invalid' }
    before { expect_any_instance_of(Exportling::Export).to receive(:invalid_atributes_message) { mock_error_message } }
  end

  describe 'GET #new' do
    let(:params)    { { klass: p_klass, params: p_params, file_type: p_file_type } }
    let(:p_params)  { { 'foo' => 'bar' } }

    context 'given valid params' do
      before { get :new, params }

      let(:p_klass)     { 'HouseCsvExporter' }
      let(:p_file_type) { 'csv' }

      it 'renders the :new view' do
        expect(response).to render_template(:new)
      end

      describe 'new export' do
        it_behaves_like :export_from_valid_params
      end
    end

    context 'given invalid params' do
      include_context :invalid_export_params
      it 'raises an error' do
        expect{ get :new, params }.to raise_error(ArgumentError, mock_error_message)
      end
    end
  end

  describe 'POST #create' do
    let(:params) { { klass: p_klass, params: p_params, file_type: p_file_type } }
    let(:p_params)    { { 'foo' => 'bar' } }


    context 'given valid params' do
      before do
        # Mocking .perform allows us to spy on this class/method
        allow(HouseCsvExporter).to receive(:perform)
        post :create, export: params
      end

      let(:p_klass)     { 'HouseCsvExporter' }
      let(:p_file_type) { 'csv' }

      it 'redirects to the :index view' do
        expect(response).to redirect_to(root_path)
      end

      it 'saves the export' do
        expect(assigns(:export)).to be_persisted
      end

      describe 'created export' do
        it_behaves_like :export_from_valid_params
      end

      it 'performs the export' do
        export = assigns(:export)
        expect(HouseCsvExporter).to have_received(:perform).with(export.id)
      end
    end

    context 'given invalid params' do
      include_context :invalid_export_params
      it 'raises an error' do
        expect{ post :create, export: params }.to raise_error(ArgumentError, mock_error_message)
      end
    end
  end

  describe 'GET #download' do
    shared_examples :download_error do
      it 'redirects to the :index view' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets an error in flash' do
        expect(flash[:error]).to eq(expected_error_message)
      end
    end

    context 'when export belongs to' do
      context 'current user' do

        it 'finds the export' do
          export.perform!
          get :download, id: export.id
          expect(assigns(:export)).to eq(export)
        end

        context 'export performed' do
          before do
            export.perform!
            get :download, id: export.id
          end

          it 'downloads the export' do
            file_name = export.file_name
            expect(response.content_type).to eq("text/csv")
            expect(response.headers["Content-Disposition"]).to eq("attachment; filename=\"#{file_name}\"")
          end
        end

        context 'export not yet performed' do
          before { get :download, id: export.id }
          let(:expected_error_message) {
            'Export cannot be downloaded until it is complete.'\
            ' Please try again later.'
          }

          it_behaves_like :download_error
        end
      end

      context 'another user' do
        before { get :download, id: other_export.id }
        let(:expected_error_message) { 'Could not find export to download' }
        it_behaves_like :download_error
      end
    end
  end
end
