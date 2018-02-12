# frozen_string_literal: true

require 'rails_helper'

describe KoboApi::Process do
  describe '.save_project' do
    let(:subject) { KoboApi::Process }
    let(:title) { 'title' }
    let(:id) { 123 }
    let(:data)  do
      { 'id' => id, 'title' => title, 'description' => 'description' }
    end

    it 'creates new Project with passed in data' do
      expect { subject.save_project(data) }
        .to change { FieldDataProject.count }.by(1)
      expect(FieldDataProject.first.name).to eq(title)
      expect(FieldDataProject.first.kobo_id).to eq(id)
      expect(FieldDataProject.first.kobo_payload).to eq(data)
    end
  end

  describe '.import_projects' do
    let(:subject) { KoboApi::Process }
    let(:data) do
      [
        { 'id' => 1, 'title' => 'title', 'description' => 'description' },
        { 'id' => 2, 'title' => 'title', 'description' => 'description' }
      ]
    end

    context 'incoming data contains new projects' do
      it 'calls save_project for each item' do
        expect(subject).to receive(:save_project).with(data.first)
        expect(subject).to receive(:save_project).with(data.second)

        subject.import_projects(data)
      end

      it 'all items are saved' do
        expect { subject.import_projects(data) }
          .to change { FieldDataProject.count }.by(2)
      end

      it 'returns true when all items are saved' do
        expect(subject.import_projects(data)).to eq(true)
      end
    end

    context 'incoming data contains previously imported projects' do
      before(:each) do
        create(:field_data_project, kobo_id: 1)
      end

      it 'calls save_project only for new items' do
        expect(subject).not_to receive(:save_project).with(data.first)
        expect(subject).to receive(:save_project).with(data.second)

        subject.import_projects(data)
      end

      it 'does not save previously imported items' do
        expect { subject.import_projects(data) }
          .to change { FieldDataProject.count }.by(1)
      end

      it 'returns true when only new items are saved' do
        expect(subject.import_projects(data)).to eq(true)
      end
    end
  end
end
