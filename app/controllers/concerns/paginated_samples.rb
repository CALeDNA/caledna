# frozen_string_literal: true

module PaginatedSamples
  extend ActiveSupport::Concern

  private

  def samples
    Sample.includes(:field_data_project)
          .approved.with_coordinates.order(:barcode).where(query_string)
  end

  def paginated_samples
    if params[:view]
      subject =
        samples.class == Array ? Kaminari.paginate_array(samples) : samples
      subject.page(params[:page])
    else
      samples
    end
  end
end
