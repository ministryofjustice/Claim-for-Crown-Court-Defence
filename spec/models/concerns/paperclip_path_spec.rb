require 'rails_helper'

ACTIVE_STORAGE_TEST_CONNECTION = ActiveRecord::Base.connection.raw_connection

RSpec.describe PaperclipPath do
  let(:test_object) { TestClass.new(id: id) }
  let(:id) { 1 }

  ACTIVE_STORAGE_TEST_CONNECTION.prepare('clear_attachment', 'DELETE FROM active_storage_attachments WHERE id=1;')
  ACTIVE_STORAGE_TEST_CONNECTION.prepare('clear_blob', 'DELETE FROM active_storage_blobs WHERE id=1;')
  ACTIVE_STORAGE_TEST_CONNECTION.prepare('add_blob', <<~SQL)
    INSERT INTO active_storage_blobs (id, key, filename, content_type, metadata, byte_size, checksum, created_at)
      VALUES (1, 'blob_key', 'testfile.csv', 100, '{}', 100, 'abc==', NOW());
  SQL
  ACTIVE_STORAGE_TEST_CONNECTION.prepare('add_attachment', <<~SQL)
    INSERT INTO active_storage_attachments (id, name, record_type, record_id, blob_id, created_at)
      VALUES (1, 'document', 'TestClass', 1, 1, NOW());
  SQL

  before do
    stub_const(
      'TestClass',
      Class.new do
        # include ActiveModel::Model
        # include ActiveRecord::Scoping
        include PaperclipPath

        attr_accessor :id, :document

        def initialize(args)
          @id = args[:id]
        end
      end
    )
  end

  describe '#paperclip_path' do
    subject(:paperclip_path) { test_object.paperclip_path(name: :document, default: default) }

    let(:default) { 'default/path' }

    context 'without an Active Storage attachment' do
      before do
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_attachment')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_blob')
      end

      it { is_expected.to eq default }
    end

    context 'with an Active Storage attachment and disk storage' do
      require 'active_storage/service/disk_service'
      let(:path_for) { 'disk-service-path' }

      before do
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_attachment')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_blob')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('add_blob')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('add_attachment')
        service = ActiveStorage::Service::DiskService.new(root: '/root/')

        allow(ActiveStorage::Blob).to receive(:service).and_return(service)
        allow(service).to receive(:path_for).with('blob_key').and_return(path_for)
      end

      after do
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_attachment')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_blob')
      end

      it { is_expected.to eq path_for }
    end

    context 'with an Active Storage attachment and S3 storage' do
      require 'active_storage/service/s3_service'
      let(:key) { 'blob_key' }

      before do
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_attachment')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_blob')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('add_blob')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('add_attachment')
        service = ActiveStorage::Service::S3Service.new(bucket: 'bucket')

        allow(ActiveStorage::Blob).to receive(:service).and_return(service)
      end

      after do
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_attachment')
        ACTIVE_STORAGE_TEST_CONNECTION.exec_prepared('clear_blob')
      end

      it { is_expected.to eq key }
    end
  end
end
