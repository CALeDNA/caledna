# frozen_string_literal: true

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
env 'IMPORT_GIS_BASE', provide('Local path to the ERSI shp files')
env 'KOBO_TOKEN', provide('Kobo API key')
env 'KOBO_MEDIA_URL', provide(
  'KoBo media URL',
  default: 'https://kc.kobotoolbox.org/attachment/original?media_file='
)
env 'IUCN_TOKEN', provide('IUCN API token')
env 'S3_ACCESS_KEY_ID', provide('S3 access key ID')
env 'S3_SECRET_ACCESS_KEY', provide('S3 secret access key')
env 'S3_REGION', provide('S3 region')
env 'S3_BUCKET', provide('S3 bucket')

puts 'setting up database'
rake 'db:drop db:create db:migrate db:seed'

puts 'creating places...'
rake 'mapgrid:import_hex_1500'
rake 'import_places:import_states'
rake 'import_places:import_watersheds'
rake 'import_places:import_la_river'
rake 'import_places:import_pour_locations'
