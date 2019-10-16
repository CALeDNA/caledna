# frozen_string_literal: true

module UpdateSamples
  def add_primers_from_asv(asv)
    sample = Sample.find(asv.sample_id)
    clean_primers = asv.primers.map { |p| clean_primers(p) }
    new_primers = clean_primers - sample.primers

    return if new_primers.blank?
    new_primers.each { |p| sample.primers << p }
    sample.save
  end

  private

  def clean_primers(primer)
    primer.gsub(/\A[Xx]/, '').gsub(/(\d)s\z/, '\1S')
  end
end
