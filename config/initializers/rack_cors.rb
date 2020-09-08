if defined? Rack::Cors
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins %w[
        https://data.ucedna.com
         http://data.ucedna.com
      ]

      resource '/assets/*',
        headers: :any,
        methods: [:get]
    end
  end
end
