module PaginatedSamples
  extend ActiveSupport::Concern

  private

  def samples
    Sample.approved.order(:barcode).where(query_string)
  end

  def paginated_samples
    if params[:view]
      samples.page(params[:page])
    else
      samples
    end
  end
end
