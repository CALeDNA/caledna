if defined? Rack::Cors
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins %w[
        https://www.protectingourriver.org
        http://www.protectingourriver.org
      ]

      resource '/assets/*',
        headers: :any,
        methods: [:get]
    end
  end
end
