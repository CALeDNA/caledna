# frozen_string_literal: true

def system_call(cmd)
  puts "Running #{cmd}"
  system cmd
  puts
end

setup :secret_key_base
env 'HOST', provide('Host', default: 'localhost:3000')
env 'ASSET_HOST', provide('Asset host', default: '//localhost:3000')
env 'DEFAULT_EMAIL', provide(
  'Default email address used by Rails mailer.',
  default: 'user@example.com'
)
env 'CAL_BASE_URL', provide(
  'URL for local Squarespace server', default: 'http://localhost:9000'
)
env 'IMPORT_GIS_BASE', provide(
  'Local path to ERSI shp files. Used when importing data for places table.',
  default: 'import_data/places'
)
env 'KOBO_TOKEN', provide('Kobo API key. Used for importing data from Kobo.')
env 'KOBO_MEDIA_URL', provide(
  'KoBo media URL. Used for copying photos from Kobo.',
  default: 'https://kc.kobotoolbox.org/attachment/original?media_file='
)
env 'IUCN_TOKEN', provide('IUCN API token. Used for updating IUCN status.')
env 'S3_ACCESS_KEY_ID', provide('S3 access key ID. S3 is used for storing ' \
  'uploaded images and files.')
env 'S3_SECRET_ACCESS_KEY', provide('S3 secret access key.')
env 'S3_REGION', provide('S3 region.')
env 'S3_BUCKET', provide('S3 bucket.')

data_url = 'https://media.githubusercontent.com/media/wykhuh/caledna_seed_data/main'
puts 'download taxa files'
system_call "curl -o import_data/taxa_1.zip #{data_url}/taxa_1.zip"
system_call 'unzip import_data/taxa_1 -d import_data/'
system_call "curl -o import_data/taxa_2.zip #{data_url}/taxa_2.zip"
system_call 'unzip import_data/taxa_2 -d import_data/'

puts 'download places files'
system_call "curl -o import_data/places.zip #{data_url}/places.zip"
system_call 'unzip import_data/places -d import_data/'

puts 'setting up database'
rake 'db:drop db:create db:migrate'

puts 'importing taxa'
# rubocop:disable Metrics/LineLength
system_call 'psql -d caledna_development -c "\copy external.ncbi_versions from ./import_data/ncbi_versions.csv delimiter \',\' csv header;" '
system_call 'psql -d caledna_development -c "\copy ncbi_divisions from ./import_data/ncbi_divisions.csv delimiter \',\' csv header;" '
system_call 'psql -d caledna_development -c "\copy ncbi_nodes from ./import_data/ncbi_nodes.csv delimiter \',\' csv header;" '
system_call 'psql -d caledna_development -c "\copy ncbi_names from ./import_data/ncbi_names.csv delimiter \',\' csv header;" '
# rubocop:enable Metrics/LineLength

puts 'importing places'
rake 'mapgrid:import_hex_1500'
rake 'import_places:import_states'
rake 'import_places:import_counties'
rake 'import_places:import_ca_places'
rake 'import_places:import_la_neighborhoods'
rake 'import_places:import_la_zip_codes'
rake 'import_places:import_watersheds'
rake 'import_places:import_la_river'
rake 'import_places:import_ucnrs'
rake 'import_places:import_ecoregions_l3'
rake 'import_places:import_ecoregions_l4'
rake 'import_places:import_la_ecotopes'
rake 'import_places:import_pour_locations'

puts 'seed database'
rake 'db:seed'

system_call 'rm -rf import_data/*'
