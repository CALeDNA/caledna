# frozen_string_literal: true

class Sample < ApplicationRecord
  include PgSearch
  include InsidePolygon
  multisearchable against: %i[barcode status_cd cvmshcp_display
                              field_data_project_name location_display]

  belongs_to :field_data_project
  has_many :photos
  has_many :extractions
  has_many :asvs

  validate :unique_approved_barcodes

  scope :processing_sample, -> { where(status_cd: :processing_sample) }
  scope :results_completed, -> { where(status_cd: :results_completed) }
  scope :approved, (lambda do
    where.not(status_cd: :submitted).where.not(status_cd: :rejected)
    .where.not(status_cd: :duplicate_barcode)
  end)
  scope :with_coordinates, (lambda do
    where.not(latitude: nil).where.not(longitude: nil)
  end)

  as_enum :status,
          %i[submitted approved rejected duplicate_barcode assigned
             processing_sample
             results_completed processed_invalid_sample],
          map: :string
  as_enum :substrate, %i[soil sediment water other], map: :string
  as_enum :ecosystem_category, %i[terrestrial aquatic], map: :string

  def status_display
    status.to_s.tr('_', ' ')
  end

  def field_data_project_name
    field_data_project.name
  end

  def research_projects
    extractions.map(&:research_projects).flatten
  end

  def inside_california?
    return false if latitude.blank? || longitude.blank?

    california = InsidePolygon::CALIFORNIA
    point = [latitude, longitude]

    inside_polygon(point, california)
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
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
  def light_display
    case kobo_data['light']
    when 'low' then 'Low-'
    when 'low_1' then 'Low'
    when 'low_2' then 'Low+'
    when 'nor' then 'Nor-'
    when 'nor_1' then 'Nor'
    when 'nor_2' then 'Nor+'
    when 'hgh' then 'Hgh-'
    when 'hgh_1' then 'Hgh'
    when 'hgh_2' then 'Hgh+'
    end
  end

  def habitat_display
    case habitat
    when 'terrestrial' then 'Terrestrial habitat, not submerged'
    when 'wetland' then 'Rarely submerged or wetland or arroyo'
    when 'freq_submerged' then 'Frequently submerged or intertidal or marsh'
    when 'full_submerged' then 'Fully submerged'
    end
  end

  def depth_display
    case depth
    when 'Top' then 'Top layer (top 3cm) soil or sediment'
    when 'Below' then 'Below top 3cm soil or sediment'
    when 'Sub_3_to_30_cm' then 'Submerged 3-30cm '
    when 'Sub_30_to_60_c_1' then 'Submerged 30-60cm'
    when 'Sub_60_to_2m' then 'Submerged 60cm-2m'
    when 'Sub_2_to_10m' then 'Submerged 2m-10m'
    when 'Sub_10_to_50m' then 'Submerged 10m-50m'
    when 'Sub_over_50m' then 'Submerged >50m'
    end
  end

  def location_display
    case location
    when 'UCNRS' then 'UC Natural Reserve'
    when 'CVMSHCP' then 'Coachella Valley MSHCP site'
    when 'AUTOMATIC_1' then nil
    when 'AUTOMATIC' then nil
    else location
    end
  end

  # rubocop:disable Metrics/AbcSize
  def cvmshcp_display
    case kobo_data['Location']
    when 'Cabazon' then 'Cabazon'
    when 'CV_Stormwater' then 'CV Stormwater Channel'
    when 'Desert_tortois' then 'Desert Tortoise'
    when 'Dos_Palmas' then 'Dos Palmas'
    when 'East_Indio' then 'East Indio Hills'
    when 'Edom_Hill' then 'Edom Hill'
    when '111_10' then 'Highway 111/I-10'
    when 'Indio_Hills_Pa' then 'Indio Hills Palms'
    when 'Indio_Joshua_L' then 'Indio/Joshua Tree Linkage'
    when 'JoshTreeNatlPa' then 'Joshua Tree National Park'
    when 'Long_Canyon' then 'Long Canyon'
    when 'Mecca_Orocopia' then 'Mecca Hills / Orocopia'
    when 'Santa_Rosa_San' then 'Santa Rosa and San Jacinto Mtns'
    when 'Snowy_Creek_Wi' then 'Snow Creek Windy Point'
    when 'Stubbe_Cottonw' then 'Stubbe and Cottonwood Canyons'
    when 'Thousand_Palms' then 'Thousand Palms'
    when 'Mission_Morong' then 'Upper Mission Creek / Big Morongo Canyon'
    when 'West_Deception' then 'West Deception Canyon'
    when 'Whitewater_Can' then 'Whitewater Canyon'
    when 'Whitewater_Flo' then 'Whitewater Floodplain'
    when 'Willow_Hole' then 'Willow Hole'
    end
  end
  # rubocop:enable Metrics/AbcSize

  def environmental_features_display
    case environmental_features
    when 'closed_water' then 'Enclosed water'
    when 'estuary' then 'Estuary (partially enclosed)'
    when 'open_water' then 'Open water'
    when 'reef' then 'Reef'
    when 'ridge' then 'Elevated ridge'
    when 'slope' then 'Slope/slant'
    when 'wash' then 'Basin/wash'
    when 'mound' then 'Rock mound'
    when 'pit' then 'Pit or ravine'
    when 'terrace' then 'Flat land/terrace'
    when 'shore' then 'Rocky shore'
    when 'beach' then 'Beach'
    when 'kelp_forest' then 'Kelp forest'
    else 'Other'
    end
  end

  def environmental_settings_display
    case environmental_settings
    when 'road' then 'On roadside'
    when 'trail' then 'On trail'
    when 'near_road' then 'Near (<5m) road or trail'
    when 'near_trail' then 'Near (<5m) buildings'
    when 'farm' then 'On farm'
    when 'garden' then 'On garden'
    when 'manmade' then 'On manmade landscape'
    when 'near_stagnant_' then 'Near (<2m) stagnant water'
    when 'near_moving_wa' then 'Near (<2m) moving water'
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

  private

  def unique_approved_barcodes
    return unless status_changed?
    return unless status == :approved

    samples = Sample.where(status_cd: :approved, barcode: barcode)
    return unless samples.count == 1

    errors.add(:unique_approved_barcodes,
               "barcode #{barcode} is already taken")
  end
end
