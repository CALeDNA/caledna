# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength, Metrics/LineLength
namespace :taxonomy_trees do
  desc 'create sql file for taxonomy_trees'
  task create_file: :environment do
    file = Rails.root.join('db').join('data').join('taxonomy_trees.sql')
    File.open(file, 'w') { |f| f.write('') }

    puts 'write kingdoms...'
    kingdoms = Taxon.valid.distinct.where(taxonRank: :kingdom).pluck(:kingdom, :taxonID)
    kingdoms.each do |kingdom|
      sql = "\nUPDATE taxa SET hierarchy = '{\"kingdom\": #{kingdom[1]}}' WHERE kingdom = '#{kingdom[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    # puts 'write phylums...'
    phylums = Taxon.valid.distinct.where(taxonRank: :phylum).pluck(:phylum, :taxonID)
    phylums.each do |phylum|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{phylum}', '#{phylum[1]}'::jsonb) WHERE phylum = '#{phylum[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    puts 'write classes...'
    class_names = Taxon.valid.distinct.where(taxonRank: :class).pluck(:className, :taxonID)
    class_names.each do |class_name|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{class}', '#{class_name[1]}'::jsonb) WHERE \"className\" = '#{class_name[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    puts 'write orders...'
    orders = Taxon.valid.distinct.where(taxonRank: :order).pluck(:order, :taxonID)
    orders.each do |order|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{order}', '#{order[1]}'::jsonb) WHERE \"order\" = '#{order[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    puts 'write families...'
    families = Taxon.valid.distinct.where(taxonRank: :family).pluck(:family, :taxonID)
    families.each do |family|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{family}', '#{family[1]}'::jsonb) WHERE family = '#{family[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    puts 'write genuses...'
    genuses = Taxon.valid.distinct.where(taxonRank: :genus).pluck(:genus, :taxonID, :parentNameUsageID)
    genuses.each do |genus|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{genus}', '#{genus[1]}'::jsonb) WHERE genus = '#{genus[0]}' AND \"parentNameUsageID\" = #{genus[2]};"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    puts 'write specific_epithets...'
    specific_epithets = Taxon.valid.distinct.where(taxonRank: :species).pluck(:specificEpithet, :taxonID, :parentNameUsageID)
    specific_epithets.each do |specific_epithet|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{species}', '#{specific_epithet[1]}'::jsonb) WHERE \"specificEpithet\" = '#{specific_epithet[0]}' AND \"parentNameUsageID\" = #{specific_epithet[2]};"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    puts 'write infraspecific_epithets...'
    infraspecific_epithets = Taxon.valid.distinct.where(taxonRank: :subspecies).pluck(:infraspecificEpithet, :taxonID, :parentNameUsageID)
    infraspecific_epithets.each do |infraspecific_epithet|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{subspecies}', '#{infraspecific_epithet[1]}'::jsonb) WHERE \"infraspecificEpithet\" = '#{infraspecific_epithet[0]}' AND \"parentNameUsageID\" = #{infraspecific_epithet[2]};"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end
end
# rubocop:enable Metrics/BlockLength, Metrics/LineLength
