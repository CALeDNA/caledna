# frozen_string_literal: true

namespace :taxonomy_trees do
  desc 'create sql file for taxonomy_trees'
  # kingdm, phylum, class, order, family are unique
  # genus and species are not unique
  task create_file: :environment do
    taxa_trees = TaxaTrees.new
    taxa_trees.kingdoms
    taxa_trees.phylums
    taxa_trees.class_names
    taxa_trees.orders
    taxa_trees.families
    taxa_trees.genuses
    taxa_trees.species
    taxa_trees.subspecies
  end
end

# rubocop:disable Metrics/MethodLength, Metrics/LineLength, Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
class TaxaTrees
  def accepted_taxa(rank, field)
    Taxon.where(taxonRank: rank, taxonomicStatus: 'accepted').pluck(field, :taxonID)
  end

  def not_accepted_taxa(rank, field)
    Taxon.where(taxonRank: rank).where.not(taxonomicStatus: 'accepted').pluck(field, :taxonID)
  end

  def kingdoms(path = 'kingdom.sql')
    file = create_file(path)

    puts 'write kingdoms...'
    taxa = Taxon.where(taxonRank: :kingdom).pluck(:kingdom, :taxonID)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = '{\"kingdom\": #{taxon[1]}}' " \
      ', rank_order = 1 ' \
      "WHERE kingdom = '#{taxon[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def phylums(path = 'phylum.sql')
    file = create_file(path)

    puts 'write phylums...'
    taxa = accepted_taxa(:phylum, :phylum)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{phylum}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 2 ' \
      "WHERE phylum = '#{taxon[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    taxa = not_accepted_taxa(:phylum, :phylum)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{phylum}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 2 ' \
      "WHERE \"taxonID\" = '#{taxon[1]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def class_names(path = 'class.sql')
    file = create_file(path)

    puts 'write classes...'
    taxa = accepted_taxa(:class, :className)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{class}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 3 ' \
      "WHERE \"className\" = '#{taxon[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    taxa = not_accepted_taxa(:class, :className)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{class}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 3 ' \
      "WHERE \"taxonID\" = '#{taxon[1]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def orders(path = 'order.sql')
    file = create_file(path)

    puts 'write orders...'
    taxa = accepted_taxa(:order, :order)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{order}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 4 ' \
      "WHERE \"order\" = '#{taxon[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    taxa = not_accepted_taxa(:order, :order)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{order}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 4 ' \
      "WHERE \"taxonID\" = '#{taxon[1]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def families(path = 'family.sql')
    file = create_file(path)

    puts 'write families...'
    taxa = accepted_taxa(:family, :family)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{family}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 5 ' \
      "WHERE family = '#{taxon[0]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    taxa = not_accepted_taxa(:family, :family)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{family}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 5 ' \
      "WHERE \"taxonID\" = '#{taxon[1]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def genuses(path = 'genus.sql')
    file = create_file(path)

    puts 'write genuses...'
    taxa = Taxon.where(taxonRank: :genus, taxonomicStatus: 'accepted')
                .pluck(:genus, :taxonID, :kingdom)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{genus}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 6 ' \
      "WHERE genus = '#{taxon[0]}' " \
      "AND kingdom = '#{taxon[2]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    taxa = Taxon.where(taxonRank: :genus)
                .where.not(taxonomicStatus: 'accepted')
                .pluck(:genus, :taxonID)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{genus}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 6 ' \
      "WHERE \"taxonID\" = '#{taxon[1]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def species(path = 'species.sql')
    file = create_file(path)

    puts 'write specific_epithets...'
    taxa = Taxon.where(taxonRank: :species, taxonomicStatus: 'accepted')
                .pluck(:specificEpithet, :taxonID, :kingdom, :genus)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{species}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 7 ' \
      "WHERE \"specificEpithet\" = '#{taxon[0]}' " \
      "AND kingdom = '#{taxon[2]}' AND genus = '#{taxon[3]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end

    taxa = Taxon.where(taxonRank: :species)
                .where.not(taxonomicStatus: 'accepted')
                .pluck(:specificEpithet, :taxonID)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{species}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 7 ' \
      "WHERE \"taxonID\" = '#{taxon[1]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def subspecies(path = 'subspecies.sql')
    file = create_file(path)

    puts 'write infraspecific_epithets...'
    taxa = Taxon.where(taxonRank: :subspecies)
                .pluck(:infraspecificEpithet, :taxonID, :kingdom, :genus, :specificEpithet)
    taxa.each do |taxon|
      sql = "\nUPDATE taxa SET hierarchy = jsonb_set(hierarchy, '{subspecies}', '#{taxon[1]}'::jsonb) " \
      ', rank_order = 8 ' \
      "WHERE \"canonicalName\" = '#{taxon[3]} #{taxon[4]} #{taxon[0]}' " \
      "AND kingdom = '#{taxon[2]}';"
      File.open(file, 'a') { |f| f.write(sql) }
    end
  end

  def create_file(path)
    file = Rails.root.join('db').join('data').join('trees').join(path)
    File.open(file, 'w') { |f| f.write('') }
    file
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/LineLength, Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
