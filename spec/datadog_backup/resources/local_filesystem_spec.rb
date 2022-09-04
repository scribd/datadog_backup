# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Resources::LocalFilesystem do
  let(:dashboard) do
    DatadogBackup::Dashboards.new_resource(id: 'abc-123-def', body: { id: 'abc-123-def' })
  end
  
  describe '#backup' do
    subject(:backup) { dashboard.backup }
    
    it 'writes a file' do
      file = instance_double('File')
      allow(File).to receive(:open).and_return(file)
      allow(file).to receive(:write)
      allow(file).to receive(:close)
      backup
      expect(file).to have_received(:write).with(%({\n  "id": "abc-123-def"\n}))
    end
  end

  describe '#delete_backup' do
    subject(:delete_backup) { dashboard.delete_backup }
    
    it 'deletes a file' do
      allow(FileUtils).to receive(:rm)
      delete_backup
      expect(FileUtils).to have_received(:rm).with(dashboard.filename)
    end
  end

  describe '#body_from_backup' do
    subject(:body_from_backup) { dashboard.body_from_backup }
    
    before do
      allow(dashboard.class).to receive(:load_from_file_by_id).and_return({"id" => "abc-123-def"})
    end

    it { is_expected.to eq({ 'id' => 'abc-123-def' }) }
  end

  describe '#filename' do
    subject(:filename) { dashboard.filename }
    
    it { is_expected.to eq("#{$options[:backup_dir]}/dashboards/abc-123-def.json") }
  end


end
