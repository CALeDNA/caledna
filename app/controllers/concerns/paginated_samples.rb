# frozen_string_literal: true

module PaginatedSamples
  extend ActiveSupport::Concern

  private

  def asvs_count(sample_id = nil)
    sql = 'SELECT sample_id, COUNT(*) ' \
          'FROM asvs ' \
          'JOIN extractions ' \
          'ON asvs.extraction_id = extractions.id ' \
          'GROUP BY sample_id '
    sql += "WHERE sample_id = #{sample_id}" if sample_id
    @asvs_count ||= ActiveRecord::Base.connection.execute(sql)
  end

  def samples
    Sample.includes(:field_data_project).approved.order(:barcode)
          .where(query_string)
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
