# frozen_string_literal: true

require 'rails_helper'

describe KoboApi::Process do
  describe '.save_project_data' do
    let(:subject) { KoboApi::Process.new }
    let(:title) { 'title' }
    let(:id) { 123 }
    let(:data) do
      { 'id' => id, 'title' => title, 'description' => 'description' }
    end

    it 'creates new Project with passed in data' do
      expect { subject.save_project_data(data) }
        .to change { FieldDataProject.count }.by(1)
      expect(FieldDataProject.first.name).to eq(title)
      expect(FieldDataProject.first.kobo_id).to eq(id)
      expect(FieldDataProject.first.kobo_payload).to eq(data)
    end
  end

  describe '.import_projects' do
    let(:subject) { KoboApi::Process.new }
    let(:data) do
      [
        { 'id' => 1, 'title' => 'title', 'description' => 'description' },
        { 'id' => 2, 'title' => 'title', 'description' => 'description' }
      ]
    end

    context 'incoming data contains new projects' do
      it 'calls save_project_data for each item' do
        expect(subject).to receive(:save_project_data).with(data.first)
        expect(subject).to receive(:save_project_data).with(data.second)

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

      it 'calls save_project_data only for new items' do
        expect(subject).not_to receive(:save_project_data).with(data.first)
        expect(subject).to receive(:save_project_data).with(data.second)

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

  describe '.import_samples' do
    let(:subject) { KoboApi::Process.new }
    let(:field_data_project) { create(:field_data_project) }
    let(:project_id) { field_data_project.id }
    let(:kobo_id) { 1 }
    let(:data) do
      [
        {
          'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
          '_id' => kobo_id,
          '_attachments' => [
            { filename: 'photo/a.jpg' },
            { filename: 'photo/b.jpg' }
          ]
        },
        {
          'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
          '_id' => 200,
          '_attachments' => [
            { filename: 'photo/c.jpg' }
          ]
        }
      ]
    end

    context 'incoming data contains new samples' do
      it 'calls save_sample_data for each item' do
        expect(subject).to receive(:save_sample_data)
          .with(project_id, kobo_id, data.first)
        expect(subject).to receive(:save_sample_data)
          .with(project_id, kobo_id, data.second)

        subject.import_samples(project_id, kobo_id, data)
      end

      it 'creates new samples' do
        expect { subject.import_samples(project_id, kobo_id, data) }
          .to change { Sample.count }.by(2)
      end

      it 'creates new photos' do
        expect { subject.import_samples(project_id, kobo_id, data) }
          .to change { Photo.count }.by(3)
      end

      it 'returns true when all items are saved' do
        expect(subject.import_samples(project_id, kobo_id, data)).to eq(true)
      end
    end

    context 'incoming data contains previously imported sample' do
      before(:each) do
        create(:sample, kobo_id: kobo_id,
                        field_data_project: field_data_project)
      end

      it 'calls save_project_data only for new items' do
        expect(subject).not_to receive(:save_sample_data)
          .with(project_id, kobo_id, data.first)
        expect(subject).to receive(:save_sample_data)
          .with(project_id, kobo_id, data.second)

        subject.import_samples(project_id, kobo_id, data)
      end

      it 'does not save previously imported samples' do
        expect { subject.import_samples(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)
      end

      it 'does not save previously imported photos' do
        expect { subject.import_samples(project_id, kobo_id, data) }
          .to change { Photo.count }.by(1)
      end

      it 'returns true when only new items are saved' do
        expect(subject.import_samples(project_id, kobo_id, data)).to eq(true)
      end
    end
  end

  describe '.save_sample_data' do
    let(:subject) { KoboApi::Process.new }
    let(:field_data_project) { create(:field_data_project) }
    let(:project_id) { field_data_project.id }

    context 'when incoming data has one sample' do
      let(:kobo_id) { 1 }
      let(:data) do
        {
          'What_is_your_kit_number_e_g_K0021' => 'K2',
          'Which_location_lette_codes_LA_LB_or_LC' => 'LB',
          'You_re_at_your_first_r_barcodes_S1_or_S2' => 'S2',
          'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
          'What_type_of_substrate_did_you' => 'soil',
          'Notes_on_recent_mana_the_sample_location' => 'notes',
          'Where_are_you_A_UC_serve_or_in_Yosemite' => 'location',
          'Enter_the_sampling_date_and_time' => '2010-01-01',
          '_submission_time' => '2010-01-02',
          '_id' => 200,
          '_attachments' => [
            { 'filename' => 'photo/c.jpg' }
          ]
        }
      end

      it 'creates a sample with incoming data' do
        expect { subject.save_sample_data(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)

        sample = Sample.first
        expect(sample.field_data_project_id).to eq(project_id)
        expect(sample.collection_date).to eq('2010-01-01')
        expect(sample.submission_date).to eq('2010-01-02')
        expect(sample.location).to eq('location')
        expect(sample.status_cd).to eq('submitted')
        expect(sample.barcode).to eq('K2-LB-S2')
        expect(sample.latitude).to eq(90)
        expect(sample.longitude).to eq(40)
        expect(sample.altitude).to eq(10)
        expect(sample.gps_precision).to eq(0)
        expect(sample.substrate).to eq(:soil)
        expect(sample.field_notes).to eq('notes')
        expect(sample.kobo_data).to eq(data)
      end
    end

    context 'when incoming data has multiple samples' do
      let(:kobo_id) { KoboApi::Process::MULTI_SAMPLE_PROJECTS.first }

      let(:data) do
        {
          'Enter_the_sampling_date_and_time' => '2010-01-01',
          '_submission_time' => '2010-01-02',
          'somewhere' => 'somewhere',
          'where' => 'where',
          'reserves' => 'reserves',
          'kit' => 'K1',
          '_id' => '100',

          'groupA/A1/A1gps' => '10 11 1 1',
          'groupA/A1/A1SS' => 'soil',
          'groupA/A1/A1picgroup/A1pic3' => 'a1-1.jpg',
          'groupA/A1/A1picgroup/A1pic2' => 'a1-2.jpg',
          'groupA/A1/A1comments' => 'comment A1',

          'groupA/A2/A2gps' => '20 22 2 2',
          'groupA/A2/A2SS' => 'sediment',
          'groupA/A2/A2picgroup/A2pic3' => 'a2-1.jpg',
          'groupA/A2/A2comments' => 'comment A2',

          'groupB/B1/barcodesB1/B1gps' => '30 33 3 3',
          'groupB/B1/B1SS' => 'soil',
          'groupB/B1/B1picgroup/B1pic2' => 'b1-1.jpg',
          'groupB/B1/B1picgroup/B1pic1' => 'b1-2.jpg',
          'groupB/B1/B1comments' => 'comment B1',

          'groupB/B2/barcodesB2/B2gps' => '40 44 4 4',
          'groupB/B2/B2SS' => 'sediment',
          'groupB/B2/B2picgroup/B2pic1' => 'b2-1.jpg',
          'groupB/B2/B2comments' => 'comment B2',

          'locC1/C1/barcodesC1/C1gps' => '50 55 5 5',
          'locC1/C1/C1SS' => 'soil',
          'locC1/C1/C1picgroup/C1pic3' => 'photo/c1-1.jpg',
          'locC1/C1/C1picgroup/C1pic1' => 'photo/c1-2.jpg',
          'locC1/C1/C1comments' => 'comment C1',

          'locC1/C2/barcodesC2/C2gps' => '60 66 6 6',
          'locC1/C2/C2SS' => 'sediment',
          'locC1/C2/C2picgroup/C2pic6' => 'c2-1.jpg',
          'locC1/C2/C2comments' => 'comment C2',

          '_attachments' => [
            { 'filename' => 'photo/a1-1.jpg' },
            { 'filename' => 'photo/a1-2.jpg' },
            { 'filename' => 'photo/a2-1.jpg' },
            { 'filename' => 'photo/b1-1.jpg' },
            { 'filename' => 'photo/b1-2.jpg' },
            { 'filename' => 'photo/b2-1.jpg' },
            { 'filename' => 'photo/c1-1.jpg' },
            { 'filename' => 'photo/c1-2.jpg' },
            { 'filename' => 'photo/c2-1.jpg' }
          ]
        }
      end

      it 'creates multiple samples' do
        expect { subject.save_sample_data(project_id, kobo_id, data) }
          .to change { Sample.count }.by(6)
      end

      it 'creates multiple photos' do
        expect { subject.save_sample_data(project_id, kobo_id, data) }
          .to change { Photo.count }.by(9)
      end

      it 'creates samples with incoming data' do
        subject.save_sample_data(project_id, kobo_id, data)

        sample_a1 = Sample.first
        expect(sample_a1.field_data_project_id).to eq(project_id)
        expect(sample_a1.collection_date).to eq('2010-01-01')
        expect(sample_a1.submission_date).to eq('2010-01-02')
        expect(sample_a1.location).to eq('somewhere; where; reserves')
        expect(sample_a1.status_cd).to eq('submitted')
        expect(sample_a1.barcode).to eq('K1-LA-S1')
        expect(sample_a1.latitude).to eq(10)
        expect(sample_a1.longitude).to eq(11)
        expect(sample_a1.altitude).to eq(1)
        expect(sample_a1.gps_precision).to eq(1)
        expect(sample_a1.substrate).to eq(:soil)
        expect(sample_a1.field_notes).to eq('comment A1')
        expect(sample_a1.kobo_data).to eq(data)

        sample_a2 = Sample.second
        expect(sample_a2.barcode).to eq('K1-LA-S2')
        expect(sample_a2.latitude).to eq(20)
        expect(sample_a2.longitude).to eq(22)
        expect(sample_a2.altitude).to eq(2)
        expect(sample_a2.gps_precision).to eq(2)
        expect(sample_a2.substrate).to eq(:sediment)
        expect(sample_a2.field_notes).to eq('comment A2')

        sample_b1 = Sample.third
        expect(sample_b1.barcode).to eq('K1-LB-S1')
        expect(sample_b1.latitude).to eq(30)
        expect(sample_b1.longitude).to eq(33)
        expect(sample_b1.altitude).to eq(3)
        expect(sample_b1.gps_precision).to eq(3)
        expect(sample_b1.substrate).to eq(:soil)
        expect(sample_b1.field_notes).to eq('comment B1')

        sample_b2 = Sample.fourth
        expect(sample_b2.barcode).to eq('K1-LB-S2')
        expect(sample_b2.latitude).to eq(40)
        expect(sample_b2.longitude).to eq(44)
        expect(sample_b2.altitude).to eq(4)
        expect(sample_b2.gps_precision).to eq(4)
        expect(sample_b2.substrate).to eq(:sediment)
        expect(sample_b2.field_notes).to eq('comment B2')

        sample_c1 = Sample.fifth
        expect(sample_c1.barcode).to eq('K1-LC-S1')
        expect(sample_c1.latitude).to eq(50)
        expect(sample_c1.longitude).to eq(55)
        expect(sample_c1.altitude).to eq(5)
        expect(sample_c1.gps_precision).to eq(5)
        expect(sample_c1.substrate).to eq(:soil)
        expect(sample_c1.field_notes).to eq('comment C1')

        sample_c2 = Sample.last
        expect(sample_c2.barcode).to eq('K1-LC-S2')
        expect(sample_c2.latitude).to eq(60)
        expect(sample_c2.longitude).to eq(66)
        expect(sample_c2.altitude).to eq(6)
        expect(sample_c2.gps_precision).to eq(6)
        expect(sample_c2.substrate).to eq(:sediment)
        expect(sample_c2.field_notes).to eq('comment C2')
      end

      it 'creates samples with identical values' do
        subject.save_sample_data(project_id, kobo_id, data)

        project_ids = Sample.pluck(:field_data_project_id).uniq
        collection_dates = Sample.pluck(:collection_date).uniq
        submission_dates = Sample.pluck(:submission_date).uniq
        locations = Sample.pluck(:location).uniq
        statuses = Sample.pluck(:status_cd).uniq

        expect(project_ids.count).to eq(1)
        expect(collection_dates.count).to eq(1)
        expect(submission_dates.count).to eq(1)
        expect(locations.count).to eq(1)
        expect(statuses.count).to eq(1)
      end

      it 'associates photos with related samples' do
        subject.save_sample_data(project_id, kobo_id, data)

        sample_ids = Sample.order(created_at: :asc).pluck(:id)
        photo_ids = Photo.order(created_at: :asc).pluck(:id)

        expect(Photo.find(photo_ids[0]).sample_id).to eq(sample_ids[0])
        expect(Photo.find(photo_ids[1]).sample_id).to eq(sample_ids[0])
        expect(Photo.find(photo_ids[2]).sample_id).to eq(sample_ids[1])
        expect(Photo.find(photo_ids[3]).sample_id).to eq(sample_ids[2])
        expect(Photo.find(photo_ids[4]).sample_id).to eq(sample_ids[2])
        expect(Photo.find(photo_ids[5]).sample_id).to eq(sample_ids[3])
        expect(Photo.find(photo_ids[6]).sample_id).to eq(sample_ids[4])
        expect(Photo.find(photo_ids[7]).sample_id).to eq(sample_ids[4])
        expect(Photo.find(photo_ids[8]).sample_id).to eq(sample_ids[5])
      end
    end
  end
end
