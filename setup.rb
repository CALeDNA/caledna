# frozen_string_literal: true

setup :secret_key_base
env 'HOST', provide('Host', default: 'localhost:3000')
env 'ASSET_HOST', provide('Asset host', default: '//localhost:3000')
env 'KOBO_TOKEN', provide('Kobo API key')

rake 'db:setup'
