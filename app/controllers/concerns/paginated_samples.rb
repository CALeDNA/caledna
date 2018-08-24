# frozen_string_literal: true

module PaginatedSamples
  extend ActiveSupport::Concern

  private

  def all_samples
    Sample.includes(:field_data_project)
          .approved.with_coordinates.order(:barcode).where(query_string)
  end

  def paginated_samples
    subject = Kaminari.paginate_array(all_samples)
    @paginated_samples ||= subject.page(params[:page])
  end
end
