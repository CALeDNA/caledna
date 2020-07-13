# frozen_string_literal: true

class Sample < ApplicationRecord
  include PgSearch
  include InsidePolygon

  before_save :update_geom

  REJECTED_STATUS = %i[rejected duplicate_barcode field_blanks].freeze

  multisearchable against: %i[
    barcode status_cd location field_project_name
    research_projects_names
  ]

  belongs_to :field_project
  has_many :kobo_photos
  has_many :asvs
  has_many :research_project_sources, as: :sourceable
  has_many :research_projects, through: :research_project_sources
  has_many :sample_primers

  validate :unique_approved_barcodes

  scope :la_river, (lambda do
    where(field_project_id: FieldProject::LA_RIVER.try(:id))
  end)
  scope :results_completed, -> { where(status_cd: :results_completed) }
  scope :approved, (lambda do
    where("status_cd  = 'approved' OR  status_cd = 'results_completed'")
  end)
  scope :with_coordinates, -> { where('latitude > -1') }

  as_enum :status,
          %i[
            submitted
            approved
            results_completed
            processed_invalid_sample
          ] + REJECTED_STATUS,
          map: :string
  as_enum :substrate, KoboValues::SUBSTRATES, map: :string
  as_enum :habitat, KoboValues::HABITAT, map: :string
  as_enum :depth, KoboValues::DEPTH, map: :string

  def status_display
    status.to_s.tr('_', ' ')
  end

  def field_project_name
    field_project.name
  end

  def inside_california?
    return false if latitude.blank? || longitude.blank?

    california = InsidePolygon::CALIFORNIA
    point = [latitude, longitude]

    inside_polygon(point, california)
  end

  def valid_barcode?
    barcode.match?(/^K\d{4}-L[ABC]-S[123]$/) ||
      barcode.match?(/^K\d{4}-(A1|B2|C3|E4|G5|K6|L7|M8|T9)$/)
  end

  def ph_display
    return if kobo_data['pH'].blank?
    kobo_data['pH'].tr('_', '.')
  end

  def moisture_display
    case kobo_data['Moisture']
    when 'dry' then 'Dry+'
    when 'dry_1' then 'Dry'
    when 'nor' then 'Nor'
    when 'wet' then 'Wet'
    when 'wet_1' then 'Wet+'
    else kobo_data['Moisture']
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
  def light_display
    case kobo_data['light'] || kobo_data['Light']
    when 'low' then 'Low-'
    when 'low_1' then 'Low'
    when 'low_2' then 'Low+'
    when 'nor' then 'Nor-'
    when 'nor_1' then 'Nor'
    when 'nor_2' then 'Nor+'
    when 'hgh' then 'Hgh-'
    when 'hgh_1' then 'Hgh'
    when 'hgh_2' then 'Hgh+'
    else kobo_data['light'] || kobo_data['Light']
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

  def research_projects_names
    research_projects.pluck(:name)
  end

  # rubocop:disable Metrics/MethodLength
  def kobo_data_display
    return {} if kobo_data == '{}'

    kobo_data.except(
      '_id',
      '_tags',
      '_uuid',
      '_notes',
      '_status',
      '__version__',
      '_attachments',
      '_geolocation',
      '_submitted_by',
      'formhub/uuid',
      'meta/instanceID',
      '_submission_time',
      '_xform_id_string',
      '_bamboo_dataset_id',
      '_validation_status',
      'Confirm_that_the_bar_barcodes_in_whirlpak',
      'What_type_of_substrate_did_you',
      'Enter_the_sampling_date_and_time',
      'What_is_your_kit_number_e_g_K0021',
      '_1_Plan_and_pack_app_dy_7_Leave_no_trace',
      '_Optional_Regarding_rns_to_share_with_us',
      'Get_the_GPS_Location_e_this_more_accurate',
      'Select_the_match_for_e_dash_on_your_tubes',
      '_Optional_Take_a_ph_ironment_you_sampled',
      'Where_are_you_A_UC_serve_or_in_Yosemite',
      'environment_feature',
      'habitat',
      'depth_your_samples',
      'Do_you_have_a_green_soil_three',
      'Describe_the_environ_tions_from_this_list',
      'Choose_from_common_environment',
      'Which_location_lette_codes_LA_LB_or_LC',
      '_optional_Describe_ou_are_sampling_from',
      'You_re_at_your_first_r_barcodes_S1_or_S2',
      '_optional_What_dept_re_your_samples_from',
      'Light',
      'Moisture',
      'Temperature_Celsius',
      'pH'
    )
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def csv_data_display
    return {} if csv_data == '{}'
    return {} if csv_data.blank?

    csv_data.except(
      'sample_id',
      'sampling_date',
      'sampling_time',
      'location',
      'latitude',
      'longitude',
      'gps_altitude',
      'gps_precision',
      'substrate',
      'habitat',
      'sampling_depth',
      'environmental_features',
      'environmental_settings',
      'field_notes'
    )
  end
  # rubocop:enable Metrics/MethodLength

  def primers_string
    sample_primers.joins(:primer).select('distinct(primers.name)')
                  .map(&:name).join(', ')
  end

  private

  def unique_approved_barcodes
    return unless status_changed?
    return unless status == :approved

    samples = Sample.where(status_cd: :approved, barcode: barcode)
    return unless samples.count == 1

    errors.add(:unique_approved_barcodes,
               "barcode #{barcode} is already taken")
  end

  def update_geom
    if latitude_changed? || longitude_changed?
      self.geom = "POINT(#{longitude} #{latitude})"
    end
  end
end
