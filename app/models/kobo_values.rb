# frozen_string_literal: true

class KoboValues
  SUBSTRATES = %w[soil sediment water other].freeze

  ENVIRONMENTAL_FEATURES_HASH = {
    'closed_water' => 'Enclosed water',
    'estuary' => 'Estuary (partially enclosed)',
    'open_water' => 'Open water',
    'reef' => 'Reef',
    'ridge' => 'Elevated ridge',
    'slope' => 'Slope/slant',
    'wash' => 'Basin/wash',
    'mound' => 'Rock mound',
    'pit' => 'Pit or ravine',
    'terrace' => 'Flat land/terrace',
    'shore' => 'Rocky shore',
    'beach' => 'Beach',
    'kelp_forest' => 'Kelp forest',
    'vernal_pool' => 'Vernal pool',
    'other' => 'Other'
  }.freeze
  ENVIRONMENTAL_FEATURES = ENVIRONMENTAL_FEATURES_HASH.values

  ENVIRONMENTAL_SETTINGS_HASH = {
    'road' => 'On roadside',
    'trail' => 'On trail',
    'near_road' => 'Near (<5m) road or trail',
    'near_trail' => 'Near (<5m) buildings',
    'farm' => 'On farm',
    'garden' => 'On garden',
    'manmade' => 'On manmade landscape',
    'near_stagnant_' => 'Near (<2m) stagnant water',
    'near_moving_wa' => 'Near (<2m) moving water',
    'on_grassland' => 'On grassland'
  }.freeze
  ENVIRONMENTAL_SETTINGS = ENVIRONMENTAL_SETTINGS_HASH.values

  DEPTH_HASH = {
    'Top' => 'Top layer (top 3cm) soil or sediment',
    'Below' => 'Below top 3cm soil or sediment',
    'Sub_3_to_30_cm' => 'Submerged 3-30cm ',
    'Sub_30_to_60_c_1' => 'Submerged 30-60cm',
    'Sub_60_to_2m' => 'Submerged 60cm-2m',
    'Sub_2_to_10m' => 'Submerged 2m-10m',
    'Sub_10_to_50m' => 'Submerged 10m-50m',
    'Sub_over_50m' => 'Submerged >50m'
  }.freeze
  DEPTH = DEPTH_HASH.values

  HABITAT_HASH = {
    'terrestrial' => 'Terrestrial habitat, not submerged',
    'wetland' => 'Rarely submerged or wetland or arroyo',
    'freq_submerged' => 'Frequently submerged or intertidal or marsh',
    'full_submerged' => 'Fully submerged'
  }.freeze
  HABITAT = HABITAT_HASH.values

  LOCATION_HASH = {
    'UCNRS' => 'UC Natural Reserve',
    'CVMSHCP' => 'Coachella Valley MSHCP site',
    'Other' => 'Somewhere else',
    'la_river_watershed' => 'LA River',
    'yosemite' => 'Yosemite',
    'san_nicolas_island' => 'San Nicolas Island',
    'mojave_desert' => 'Mojave Desert',
    'White_mtns' => 'White Mountains',
    'Tahoe_National' => 'Tahoe National Forest'
  }.freeze
  LOCATION = LOCATION_HASH.values

  UCNR_HASH = {
    'angelo_coast_r' => 'Angelo Coast Range Reserve',
    'a_o_nuevo_isla' => 'Año Nuevo Island Reserve',
    'blue_oak_ranch' => 'Blue Oak Ranch Reserve',
    'bodega_marine_' => 'Bodega Marine Reserve',
    'box_springs_re' => 'Box Springs Reserve',
    'boyd_deep_cany' => 'Boyd Deep Canyon Desert Research Center',
    'burns_pi_on_ri' => 'Burns Piñon Ridge Reserve',
    'carpinteria_sa' => 'Carpinteria Salt Marsh Reserve',
    'chickering_ame' => 'Chickering American River Reserve',
    'coal_oil_point' => 'Coal Oil Point Natural Reserve',
    'dawson_los_mon' => 'Dawson Los Monos Canyon Reserve',
    'elliott_chapar' => 'Elliott Chaparral Reserve',
    'emerson_oaks_r' => 'Emerson Oaks Reserve',
    'fort_ord_natur' => 'Fort Ord Natural Reserve',
    'hastings_natur' => 'Hastings Natural History Reservation',
    'james_san_jaci' => 'James San Jacinto Mountains Reserve',
    'jenny_pygmy_fo' => 'Jenny Pygmy Forest Reserve',
    'jepson_prairie' => 'Jepson Prairie Reserve',
    'kendall_frost_' => 'Kendall-Frost Mission Bay Marsh Reserve',
    'landels_hill_b' => 'Landels-Hill Big Creek Reserve',
    'mclaughlin_nat' => 'McLaughlin Natural Reserve',
    'merced_vernal_' => 'Merced Vernal Pools and Grassland Reserve',
    'motte_rimrock_' => 'Motte Rimrock Reserve',
    'kenneth_s__nor' => 'Kenneth S. Norris Rancho Marino Reserve',
    'quail_ridge_re' => 'Quail Ridge Reserve',
    'sagehen_creek_' => 'Sagehen Creek Field Station',
    'san_joaquin_ma' => 'San Joaquin Marsh Reserve',
    'santa_cruz_isl' => ' Santa Cruz Island Reserve',
    'scripps_coasta' => 'Scripps Coastal Reserve',
    'sedgwick_reser' => 'Sedgwick Reserve',
    'sierra_nevada_' =>
      'Sierra Nevada Research Station - Yosemite Field Station',
    'stebbins_cold_' => 'Stebbins Cold Canyon Reserve',
    'steele_burnand' => 'Steele/Burnand Anza-Borrego Desert Research Center',
    'stunt_ranch_sa' => 'Stunt Ranch Santa Monica Mountains Reserve',
    'sweeney_granit' => 'Sweeney Granite Mountains Desert Research Center',
    'valentine_east' => 'Valentine Eastern Sierra Reserve Laboratory and Camp',
    'white_mountain' => 'White Mountain Research Center',
    'younger_lagoon' => 'Younger Lagoon Reserve'
  }.freeze
  UCNR = UCNR_HASH.values

  CVMSHCP_HASH = {
    'Cabazon' => 'Cabazon',
    'CV_Stormwater' => 'CV Stormwater Channel',
    'Desert_tortois' => 'Desert Tortoise',
    'Dos_Palmas' => 'Dos Palmas',
    'East_Indio' => 'East Indio Hills',
    'Edom_Hill' => 'Edom Hill',
    '111_10' => 'Highway 111/I-10',
    'Indio_Hills_Pa' => 'Indio Hills Palms',
    'Indio_Joshua_L' => 'Indio/Joshua Tree Linkage',
    'JoshTreeNatlPa' => 'Joshua Tree National Park',
    'Long_Canyon' => 'Long Canyon',
    'Mecca_Orocopia' => 'Mecca Hills / Orocopia',
    'Santa_Rosa_San' => 'Santa Rosa and San Jacinto Mtns',
    'Snowy_Creek_Wi' => 'Snow Creek Windy Point',
    'Stubbe_Cottonw' => 'Stubbe and Cottonwood Canyons',
    'Thousand_Palms' => 'Thousand Palms',
    'Mission_Morong' => 'Upper Mission Creek / Big Morongo Canyon',
    'West_Deception' => 'West Deception Canyon',
    'Whitewater_Can' => 'Whitewater Canyon',
    'Whitewater_Flo' => 'Whitewater Floodplain',
    'Willow_Hole' => 'Willow Hole'
  }.freeze
  CVMSHCP = CVMSHCP_HASH.values

  LA_RIVER_HASH = {
    'aliso_canyon_w' => 'Aliso Canyon Wash',
    'arroyo_seco' => 'Arroyo Seco ',
    'bell_creek' => 'Bell Creek',
    'bull_creek' => 'Bull Creek',
    'burbank_wester' => 'Burbank Western Channel ',
    'compton_creek' => 'Compton Creek ',
    'dry_canyon_cre' => 'Dry Canyon Creek ',
    'la_river' => 'LA River',
    'mccoy_canyon_c' => 'McCoy Canyon Creek',
    'monrovia_canyo' => 'Monrovia Canyon Creek',
    'pacoima_wash' => 'Pacoima Wash ',
    'rio_hondo' => 'Rio Hondo ',
    'tujunga_wash' => 'Tujunga Wash ',
    'verdugo_wash' => 'Verdugo Wash '
  }.freeze
  LA_RIVER = LA_RIVER_HASH.values

  LIGHT_HASH = {
    'low' => 'Low-',
    'low_1' => 'Low',
    'low_2' => 'Low+',
    'nor' => 'Nor-',
    'nor_1' => 'Nor',
    'nor_2' => 'Nor+',
    'hgh' => 'Hgh-',
    'hgh_1' => 'Hgh',
    'hgh_2' => 'Hgh+'
  }.freeze
  LIGHT = LIGHT_HASH.values
end
