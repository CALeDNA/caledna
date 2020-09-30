# frozen_string_literal: true

module AutoUpdateGeom
  extend ActiveSupport::Concern

  included do
    before_save do
      if geom.blank? && longitude.present? && latitude.present?
        self.geom = "POINT(#{longitude} #{latitude})"
      elsif point_geom? && (latitude_changed? || longitude_changed?)
        self.geom = "POINT(#{longitude} #{latitude})"
      end
    end

    after_save do
      next if geom.blank?

      id_field = self.class == PourGbifOccurrence ? 'gbif_id' : 'id'

      sql = "UPDATE #{self.class.table_name} SET " \
        'geom_projected = ST_Transform(ST_SetSRID' \
        "(geom, #{Geospatial::SRID}), #{Geospatial::SRID_PROJECTED}) " \
        "WHERE #{id_field} = #{id}"

      ActiveRecord::Base.connection.exec_query(sql)
    end
  end

  def point_geom?
    geom.to_s.starts_with?('POINT')
  end
end
