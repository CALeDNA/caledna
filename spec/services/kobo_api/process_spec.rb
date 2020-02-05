# frozen_string_literal: true

require 'rails_helper'

describe KoboApi::Process do
  let(:dummy_class) { Class.new { extend KoboApi::Process } }

  describe '.save_project_data' do
    def subject(data)
      dummy_class.save_project_data(data)
    end

    let(:title) { 'title' }
    let(:id) { 123 }
    let(:data) do
      { 'id' => id, 'title' => title, 'description' => 'description' }
    end

    it 'creates new Project with passed in data' do
      expect { subject(data) }
        .to change { FieldProject.count }.by(1)
      expect(FieldProject.first.name).to eq(title)
      expect(FieldProject.first.kobo_id).to eq(id)
      expect(FieldProject.first.kobo_payload).to eq(data)
    end
  end

  describe '.import_kobo_projects' do
    def subject(data)
      dummy_class.import_kobo_projects(data)
    end

    let(:data) do
      [
        { 'id' => 1, 'title' => 'title', 'description' => 'description' },
        { 'id' => 2, 'title' => 'title', 'description' => 'description' }
      ]
    end

    context 'incoming data contains new projects' do
      it 'all items are saved' do
        expect { subject(data) }
          .to change { FieldProject.count }.by(2)
      end

      it 'returns true when all items are saved' do
        expect(subject(data)).to eq(true)
      end
    end

    context 'incoming data contains previously imported projects' do
      before(:each) do
        create(:field_project, kobo_id: 1)
      end

      it 'does not save previously imported items' do
        expect { subject(data) }
          .to change { FieldProject.count }.by(1)
      end

      it 'returns true when only new items are saved' do
        expect(subject(data)).to eq(true)
      end
    end
  end

  describe '.import_kobo_samples' do
    include ActiveJob::TestHelper

    def subject(project_id, kobo_id, hash_payload)
      dummy_class.import_kobo_samples(project_id, kobo_id, hash_payload)
    end

    let(:field_project) { create(:field_project) }
    let(:project_id) { field_project.id }
    let(:kobo_id) { 1 }
    let(:data) do
      [
        {
          'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
          '_id' => kobo_id
        },
        {
          'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
          '_id' => 200
        }
      ]
    end

    context 'incoming data contains new samples' do
      it 'enqueues ImportKoboSampleJob for each new samples' do
        expect { subject(project_id, kobo_id, data) }
          .to have_enqueued_job(ImportKoboSampleJob).at_least(2).times
      end

      it 'returns number of new samples' do
        expect(subject(project_id, kobo_id, data)).to eq(2)
      end
    end

    context 'incoming data contains previously imported sample' do
      before(:each) do
        create(:sample, kobo_id: kobo_id,
                        field_project: field_project)
      end

      it 'enqueues ImportKoboSampleJob only for new samples' do
        expect { subject(project_id, kobo_id, data) }
          .to have_enqueued_job(ImportKoboSampleJob).at_least(1).times
      end

      it 'returns number of new samples' do
        expect(subject(project_id, kobo_id, data)).to eq(1)
      end
    end
  end

  describe '.save_sample_data' do
    def subject(project_id, kobo_id, hash_payload)
      dummy_class.stub(:open_and_read).and_return(Tempfile.new('foo'))
      dummy_class.save_sample_data(project_id, kobo_id, hash_payload)
    end

    let(:field_project) { create(:field_project) }
    let(:project_id) { field_project.id }

    context 'when incoming data has one sample V1' do
      let(:kobo_id) { FieldProject::SINGLE_SAMPLE_PROJECTS_V1.first }
      let(:data) do
        {
          'What_is_your_kit_number_e_g_K0021' => 'K2',
          'Which_location_lette_codes_LA_LB_or_LC' => 'LB',
          'You_re_at_your_first_r_barcodes_S1_or_S2' => 'S2',
          'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
          'What_type_of_substrate_did_you' => 'soil',
          'Notes_on_recent_mana_the_sample_location' => 'notes',
          '_Optional_Regarding_rns_to_share_with_us' => 'notes2',
          'Where_are_you_A_UC_serve_or_in_Yosemite' => 'location',
          'Location' => 'location2',
          'Enter_the_sampling_date_and_time' => '2010-01-01',
          '_submission_time' => '2010-01-02',
          '_id' => 200,
          '_attachments' => [
            { 'filename' => 'photo/c.jpg' }
          ]
        }
      end

      it 'creates a sample with incoming data' do
        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)

        sample = Sample.first
        expect(sample.field_project_id).to eq(project_id)
        expect(sample.collection_date).to eq('2010-01-01')
        expect(sample.submission_date).to eq('2010-01-02')
        expect(sample.location).to eq('location location2')
        expect(sample.status_cd).to eq('submitted')
        expect(sample.barcode).to eq('K2-LB-S2')
        expect(sample.latitude).to eq(90)
        expect(sample.longitude).to eq(40)
        expect(sample.altitude).to eq(10)
        expect(sample.gps_precision).to eq(0)
        expect(sample.substrate).to eq(:soil)
        expect(sample.field_notes).to eq('notes notes2')
        expect(sample.kobo_data).to eq(data)
      end
    end

    context 'when incoming data has one sample V2' do
      let(:kobo_id) { 1 }
      let(:habitat_raw) { KoboValues::HABITAT_HASH.keys.first }
      let(:habitat) { KoboValues::HABITAT.first }
      let(:depth_raw) { KoboValues::DEPTH_HASH.keys.first }
      let(:depth) { KoboValues::DEPTH.first }
      let(:feature_raw) { KoboValues::ENVIRONMENTAL_FEATURES_HASH.keys.first }
      let(:feature) { KoboValues::ENVIRONMENTAL_FEATURES.first }
      let(:location_raw) { KoboValues::LOCATION_HASH.keys.first }
      let(:location) { KoboValues::LOCATION.first }
      let(:ucnr_raw) { KoboValues::UCNR_HASH.keys.first }
      let(:ucnr) { KoboValues::UCNR.first }
      let(:cvmshcp_raw) { KoboValues::CVMSHCP_HASH.keys.second }
      let(:cvmshcp) { KoboValues::CVMSHCP.second }
      let(:la_river_raw) { KoboValues::LA_RIVER_HASH.keys.first }
      let(:la_river) { KoboValues::LA_RIVER.first }
      let(:settings_raw) { KoboValues::ENVIRONMENTAL_SETTINGS_HASH.keys.first }
      let(:settings) { KoboValues::ENVIRONMENTAL_SETTINGS.first }

      let(:data) do
        {
          'What_is_your_kit_number_e_g_K0021' => 'K2',
          'Which_location_lette_codes_LA_LB_or_LC' => 'LB',
          'You_re_at_your_first_r_barcodes_S1_or_S2' => 'S2',
          'Get_the_GPS_Location_e_this_more_accurate' => '90, 40, 10, 0',
          'What_type_of_substrate_did_you' => 'soil',
          '_Optional_Regarding_rns_to_share_with_us' => 'notes',
          'Where_are_you_A_UC_serve_or_in_Yosemite' => location_raw,
          'If_at_a_UC_Natural_R_ve_select_which_one' => ucnr_raw,
          '_optional_Describe_ou_are_sampling_from' => habitat_raw,
          '_optional_What_dept_re_your_samples_from' => depth_raw,
          'Choose_from_common_environment' => feature_raw,
          'Describe_the_environ_tions_from_this_list' => settings_raw,
          'Enter_the_sampling_date_and_time' => '2010-01-01',
          '_submission_time' => '2010-01-02',
          '_id' => 200,
          '_attachments' => [
            { 'filename' => 'photo/c.jpg' }
          ]
        }
      end

      it 'creates a sample with incoming data' do
        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)

        sample = Sample.first
        expect(sample.field_project_id).to eq(project_id)
        expect(sample.collection_date).to eq('2010-01-01')
        expect(sample.submission_date).to eq('2010-01-02')
        expect(sample.location)
          .to eq("#{location}; #{ucnr}")
        expect(sample.status_cd).to eq('submitted')
        expect(sample.barcode).to eq('K2-LB-S2')
        expect(sample.latitude).to eq(90)
        expect(sample.longitude).to eq(40)
        expect(sample.altitude).to eq(10)
        expect(sample.gps_precision).to eq(0)
        expect(sample.substrate).to eq(:soil)
        expect(sample.field_notes).to eq('notes')
        expect(sample.habitat_cd).to eq(habitat)
        expect(sample.depth_cd).to eq(depth)
        expect(sample.environmental_features).to eq([feature])
        expect(sample.environmental_settings).to eq([settings])
        expect(sample.kobo_data).to eq(data)
      end

      it 'handles Coachella Valley locations' do
        location_raw = KoboValues::LOCATION_HASH.keys.second
        location = KoboValues::LOCATION.second
        data = {
          'Where_are_you_A_UC_serve_or_in_Yosemite' => location_raw,
          'Location' => cvmshcp_raw
        }

        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)
        sample = Sample.first

        expect(sample.location).to eq("#{location}; #{cvmshcp}")
      end

      it 'handles LA River locations' do
        location_raw = KoboValues::LOCATION_HASH.keys.fourth
        location = KoboValues::LOCATION.fourth
        data = {
          'Where_are_you_A_UC_serve_or_in_Yosemite' => location_raw,
          'If_at_LA_River_water_which_body_of_water' => la_river_raw
        }

        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)
        sample = Sample.first

        expect(sample.location).to eq("#{location}; #{la_river}")
      end

      it 'handles multiple environmental features' do
        feature2_raw = KoboValues::ENVIRONMENTAL_FEATURES_HASH.keys.second
        feature2 = KoboValues::ENVIRONMENTAL_FEATURES.second
        feature3_raw = KoboValues::ENVIRONMENTAL_FEATURES_HASH.keys.third
        feature3 = KoboValues::ENVIRONMENTAL_FEATURES.third

        data = {
          'Choose_from_common_environment' => "#{feature_raw} #{feature2_raw}",
          'environment_feature' => feature3_raw,
          'If_other_describe_t_nvironmental_feature' => 'custom feature'
        }

        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)
        sample = Sample.first

        expect(sample.environmental_features)
          .to eq([feature, feature2, feature3, 'custom feature'])
      end

      it 'handles multiple environmental settings' do
        settings2_raw = KoboValues::ENVIRONMENTAL_SETTINGS_HASH.keys.second
        settings2 = KoboValues::ENVIRONMENTAL_SETTINGS.second

        data = {
          'Describe_the_environ_tions_from_this_list' =>
            "#{settings_raw} #{settings2_raw}"
        }

        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)
        sample = Sample.first

        expect(sample.environmental_settings)
          .to eq([settings, settings2])
      end
    end

    context 'when incoming data has two part kit number' do
      let(:kobo_id) { 1 }
      let(:data) do
        {
          'What_is_your_kit_number_e_g_K0021' => 'K1',
          'Select_the_match_for_e_dash_on_your_tubes' => 'A1'
        }
      end

      it 'creates a sample with incoming data' do
        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)

        sample = Sample.first
        expect(sample.barcode).to eq('K1-A1')
      end

      it 'uses uppercase for barcodes' do
        data = {
          'What_is_your_kit_number_e_g_K0021' => 'k1',
          'Select_the_match_for_e_dash_on_your_tubes' => 'a1'
        }
        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(1)

        sample = Sample.first
        expect(sample.barcode).to eq('K1-A1')
      end
    end

    context 'when incoming data has multiple samples' do
      let(:kobo_id) { FieldProject::MULTI_SAMPLE_PROJECTS.first }

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
        expect { subject(project_id, kobo_id, data) }
          .to change { Sample.count }.by(6)
      end

      it 'creates multiple photos' do
        expect { subject(project_id, kobo_id, data) }
          .to change { KoboPhoto.count }.by(9)
      end

      it 'attaches a photo via ActiveStorage' do
        expect { subject(project_id, kobo_id, data) }
          .to change(ActiveStorage::Attachment, :count).by(9)
      end

      it 'creates samples with incoming data' do
        subject(project_id, kobo_id, data)

        sample_a1 = Sample.first
        expect(sample_a1.field_project_id).to eq(project_id)
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
        subject(project_id, kobo_id, data)

        project_ids = Sample.pluck(:field_project_id).uniq
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

      it 'associates kobo photos with related samples' do
        subject(project_id, kobo_id, data)

        sample_ids = Sample.order(created_at: :asc).pluck(:id)
        photo_ids = KoboPhoto.order(created_at: :asc).pluck(:id)

        expect(KoboPhoto.find(photo_ids[0]).sample_id).to eq(sample_ids[0])
        expect(KoboPhoto.find(photo_ids[1]).sample_id).to eq(sample_ids[0])
        expect(KoboPhoto.find(photo_ids[2]).sample_id).to eq(sample_ids[1])
        expect(KoboPhoto.find(photo_ids[3]).sample_id).to eq(sample_ids[2])
        expect(KoboPhoto.find(photo_ids[4]).sample_id).to eq(sample_ids[2])
        expect(KoboPhoto.find(photo_ids[5]).sample_id).to eq(sample_ids[3])
        expect(KoboPhoto.find(photo_ids[6]).sample_id).to eq(sample_ids[4])
        expect(KoboPhoto.find(photo_ids[7]).sample_id).to eq(sample_ids[4])
        expect(KoboPhoto.find(photo_ids[8]).sample_id).to eq(sample_ids[5])
      end

      it 'attaches a photo to kobo photo' do
        subject(project_id, kobo_id, data)

        KoboPhoto.all.each do |kobo_photo|
          expect(kobo_photo.photo)
            .to be_an_instance_of(ActiveStorage::Attached::One)
        end
      end
    end
  end
end
