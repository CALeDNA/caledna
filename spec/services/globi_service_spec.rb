# frozen_string_literal: true

require 'rails_helper'

describe 'GlobiService' do
  let(:dummy_class) { Class.new { extend GlobiService } }

  let(:ncbi_name_1) { 'ncbi_name_1' }
  let(:ncbi_id_1) { 1 }
  let(:cal_id_1) { 10 }
  let(:source_globi_name) { 'source_globi_name' }
  let(:source_asvs_count) { 30 }

  let(:ncbi_name_2) { 'ncbi_name_2' }
  let(:ncbi_id_2) { 2 }
  let(:cal_id_2) { 20 }
  let(:target_globi_name) { 'target_globi_name' }
  let(:target_asvs_count) { 40 }

  let(:neutral) { InteractionType::NEUTRAL_TYPES.first }
  let(:neutral_display) { format_type(neutral) }
  let(:active) { InteractionType::ACTIVE_TYPES.first }
  let(:active_display) { format_type(active) }
  let(:passive) { InteractionType::PASSIVE_TYPES.first }
  let(:passive_display) { format_type(passive) }

  def create_ncbi_node(name:, taxon_id:, ncbi_id:, asvs_count:)
    create(:ncbi_node, canonical_name: name, taxon_id: taxon_id,
                       ncbi_id: ncbi_id, asvs_count: asvs_count,
                       common_names: 'a|b')
  end

  # rubocop:disable Metrics/MethodLength
  def create_interaction(
    type, source_ncbi_id:, target_ncbi_id:, source_ncbi_name: ncbi_name_1,
    target_ncbi_name: ncbi_name_2
  )

    interaction = create(
      :globi_interaction,
      interactionTypeName: type,
      targetTaxonName: target_globi_name,
      target_ncbi_id: target_ncbi_id,
      sourceTaxonName: source_globi_name,
      source_ncbi_id: source_ncbi_id
    )

    interaction.instance_eval { class << self; self end }
               .send(:attr_accessor, :interaction_type,
                     :source_cal_id,
                     :source_ncbi_name,
                     :source_ncbi_id,
                     :source_asvs_count,
                     :source_common_names,
                     :target_cal_id,
                     :target_ncbi_name,
                     :target_ncbi_id,
                     :target_asvs_count,
                     :target_common_names)

    interaction.interaction_type = type

    interaction.source_cal_id = cal_id_1
    interaction.source_ncbi_name = source_ncbi_name
    interaction.source_ncbi_id = source_ncbi_id
    interaction.source_asvs_count = source_asvs_count
    interaction.source_common_names = 'a|b'

    interaction.target_cal_id = cal_id_2
    interaction.target_ncbi_name = target_ncbi_name
    interaction.target_ncbi_id = target_ncbi_id
    interaction.target_asvs_count = target_asvs_count
    interaction.target_common_names = 'c|d'
    interaction
  end
  # rubocop:enable Metrics/MethodLength

  def format_type(type)
    type.underscore.humanize.downcase
  end

  describe '#display_globi_for' do
    def subject(ncbi_id)
      dummy_class.display_globi_for(ncbi_id)
    end

    context 'when both source and taxon are ncbi taxa' do
      context 'when source and target matches a given taxon id' do
        it 'puts neutral interaction into the neutral bin' do
          create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: ncbi_id_1)
          create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_1,
                           ncbi_id: ncbi_id_1, asvs_count: source_asvs_count)

          expected = {
            active: [],
            passive: [],
            neutral: [
              { type: neutral_display, taxon_name: ncbi_name_1,
                taxon_id: cal_id_1, asvs_count: source_asvs_count,
                common_names: 'a|b' }
            ]
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end

        it 'puts active interaction into the active bin' do
          create_interaction(active, source_ncbi_id: ncbi_id_1,
                                     target_ncbi_id: ncbi_id_1)
          create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_1,
                           ncbi_id: ncbi_id_1, asvs_count: source_asvs_count)

          expected = {
            active: [
              { type: active_display, taxon_name: ncbi_name_1,
                taxon_id: cal_id_1, asvs_count: source_asvs_count,
                common_names: 'a|b' }
            ],
            passive: [],
            neutral: []
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end

        it 'puts passive interaction into the passive bin' do
          create_interaction(passive, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: ncbi_id_1)
          create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_1,
                           ncbi_id: ncbi_id_1, asvs_count: source_asvs_count)

          expected = {
            active: [],
            passive: [
              { type: passive_display, taxon_name: ncbi_name_1,
                taxon_id: cal_id_1, asvs_count: source_asvs_count,
                common_names: 'a|b' }
            ],
            neutral: []
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end
      end

      context 'when source matches a given taxon id' do
        before(:each) do
          create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_1,
                           ncbi_id: ncbi_id_1, asvs_count: source_asvs_count)
          create_ncbi_node(name: ncbi_name_2, taxon_id: cal_id_2,
                           ncbi_id: ncbi_id_2, asvs_count: target_asvs_count)
        end
        it 'puts neutral interaction with target data into the neutral bin' do
          create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: ncbi_id_2)

          expected = {
            active: [],
            passive: [],
            neutral: [
              { type: neutral_display, taxon_name: ncbi_name_2,
                taxon_id: cal_id_2, asvs_count: target_asvs_count,
                common_names: 'a|b' }
            ]
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end

        it 'puts active interaction with target data into the active bin' do
          create_interaction(active, source_ncbi_id: ncbi_id_1,
                                     target_ncbi_id: ncbi_id_2)

          expected = {
            active: [
              { type: active_display, taxon_name: ncbi_name_2,
                taxon_id: cal_id_2, asvs_count: target_asvs_count,
                common_names: 'a|b' }
            ],
            passive: [],
            neutral: []
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end

        it 'puts passive interaction with target data  into the passive bin' do
          create_interaction(passive, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: ncbi_id_2)

          expected = {
            active: [],
            passive: [
              { type: passive_display, taxon_name: ncbi_name_2,
                taxon_id: cal_id_2, asvs_count: target_asvs_count,
                common_names: 'a|b' }
            ],
            neutral: []
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end
      end

      context 'when target matches a given taxon id' do
        before(:each) do
          create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_2,
                           ncbi_id: ncbi_id_2, asvs_count: source_asvs_count)
          create_ncbi_node(name: ncbi_name_2, taxon_id: cal_id_1,
                           ncbi_id: ncbi_id_1, asvs_count: target_asvs_count)
        end

        it 'puts neutral interaction with source data into the neutral bin' do
          create_interaction(neutral, source_ncbi_id: ncbi_id_2,
                                      target_ncbi_id: ncbi_id_1)

          expected = {
            active: [],
            passive: [],
            neutral: [
              { type: neutral_display, taxon_name: ncbi_name_1,
                taxon_id: cal_id_2, asvs_count: source_asvs_count,
                common_names: 'a|b' }
            ]
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end

        it 'puts active interaction with source data into the passive bin' do
          create_interaction(active, source_ncbi_id: ncbi_id_2,
                                     target_ncbi_id: ncbi_id_1)

          expected = {
            active: [],
            passive: [
              { type: passive_display, taxon_name: ncbi_name_1,
                taxon_id: cal_id_2, asvs_count: source_asvs_count,
                common_names: 'a|b' }
            ],
            neutral: []
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end

        it 'puts passive interaction with source data into the active bin' do
          create_interaction(passive, source_ncbi_id: ncbi_id_2,
                                      target_ncbi_id: ncbi_id_1)

          expected = {
            active: [
              { type: active_display, taxon_name: ncbi_name_1,
                taxon_id: cal_id_2, asvs_count: source_asvs_count,
                common_names: 'a|b' }
            ],
            passive: [],
            neutral: []
          }
          expect(subject(ncbi_id_1)).to eq(expected)
        end
      end
    end

    it 'returns only one record when multiple records have same type, ' \
      'source taxon, target taxon' do
      create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                  target_ncbi_id: ncbi_id_2)
      create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                  target_ncbi_id: ncbi_id_2)
      create_interaction(active, source_ncbi_id: ncbi_id_1,
                                 target_ncbi_id: ncbi_id_2)
      create_interaction(active, source_ncbi_id: ncbi_id_1,
                                 target_ncbi_id: ncbi_id_2)
      create_interaction(passive, source_ncbi_id: ncbi_id_1,
                                  target_ncbi_id: ncbi_id_2)
      create_interaction(passive, source_ncbi_id: ncbi_id_1,
                                  target_ncbi_id: ncbi_id_2)
      create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_1,
                       ncbi_id: ncbi_id_1, asvs_count: source_asvs_count)
      create_ncbi_node(name: ncbi_name_2, taxon_id: cal_id_2,
                       ncbi_id: ncbi_id_2, asvs_count: target_asvs_count)

      expected = {
        active: [
          { type: active_display, taxon_name: ncbi_name_2, taxon_id: cal_id_2,
            asvs_count: target_asvs_count, common_names: 'a|b' }
        ],
        passive: [
          { type: passive_display, taxon_name: ncbi_name_2, taxon_id: cal_id_2,
            asvs_count: target_asvs_count, common_names: 'a|b' }
        ],
        neutral: [
          { type: neutral_display, taxon_name: ncbi_name_2, taxon_id: cal_id_2,
            asvs_count: target_asvs_count, common_names: 'a|b' }
        ]
      }
      expect(subject(ncbi_id_1)).to eq(expected)
    end

    it 'returns multiple record when records have different type, ' \
      'source taxon, target taxon' do
      create_interaction(neutral, source_ncbi_id: 1, target_ncbi_id: 2)
      create_interaction(neutral, source_ncbi_id: 3, target_ncbi_id: 1)
      create_interaction(active, source_ncbi_id: 1, target_ncbi_id: 4)
      create_interaction(active, source_ncbi_id: 5, target_ncbi_id: 1)
      create_interaction(passive, source_ncbi_id: 1, target_ncbi_id: 6)
      create_interaction(passive, source_ncbi_id: 7, target_ncbi_id: 1)
      create_ncbi_node(name: ncbi_name_1, taxon_id: 1, ncbi_id: 1,
                       asvs_count: source_asvs_count)
      create_ncbi_node(name: ncbi_name_2, taxon_id: 2, ncbi_id: 2,
                       asvs_count: target_asvs_count)
      create_ncbi_node(name: ncbi_name_1, taxon_id: 3, ncbi_id: 3,
                       asvs_count: source_asvs_count)
      create_ncbi_node(name: ncbi_name_2, taxon_id: 4, ncbi_id: 4,
                       asvs_count: target_asvs_count)
      create_ncbi_node(name: ncbi_name_1, taxon_id: 5, ncbi_id: 5,
                       asvs_count: source_asvs_count)
      create_ncbi_node(name: ncbi_name_2, taxon_id: 6, ncbi_id: 6,
                       asvs_count: target_asvs_count)
      create_ncbi_node(name: ncbi_name_1, taxon_id: 7, ncbi_id: 7,
                       asvs_count: source_asvs_count)

      expected = {
        active: [
          { type: active_display, taxon_name: ncbi_name_2, taxon_id: 4,
            asvs_count: target_asvs_count, common_names: 'a|b' },
          { type: active_display, taxon_name: ncbi_name_1, taxon_id: 7,
            asvs_count: source_asvs_count, common_names: 'a|b' }
        ],
        passive: [
          { type: passive_display, taxon_name: ncbi_name_2, taxon_id: 6,
            asvs_count: target_asvs_count, common_names: 'a|b' },
          { type: passive_display, taxon_name: ncbi_name_1, taxon_id: 5,
            asvs_count: source_asvs_count, common_names: 'a|b' }
        ],
        neutral: [
          { type: neutral_display, taxon_name: ncbi_name_2, taxon_id: 2,
            asvs_count: target_asvs_count, common_names: 'a|b' },
          { type: neutral_display, taxon_name: ncbi_name_1, taxon_id: 3,
            asvs_count: source_asvs_count, common_names: 'a|b' }
        ]
      }

      expect(subject(1)[:active]).to match_array(expected[:active])
      expect(subject(1)[:passive]).to match_array(expected[:passive])
      expect(subject(1)[:neutral]).to match_array(expected[:neutral])
    end

    it 'processes interaction when only source is a ncbi taxon' do
      create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                  target_ncbi_id: nil)
      create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_1,
                       ncbi_id: ncbi_id_1, asvs_count: source_asvs_count)

      expected = {
        active: [],
        passive: [],
        neutral: [
          { type: neutral_display, taxon_name: target_globi_name,
            taxon_id: nil, asvs_count: nil, common_names: nil }
        ]
      }
      expect(subject(ncbi_id_1)).to eq(expected)
    end

    it 'processes interaction when only target is a ncbi taxon' do
      create_interaction(neutral, source_ncbi_id: nil,
                                  target_ncbi_id: ncbi_id_1)
      create_ncbi_node(name: ncbi_name_2, taxon_id: cal_id_1,
                       ncbi_id: ncbi_id_1, asvs_count: target_asvs_count)

      expected = {
        active: [],
        passive: [],
        neutral: [
          { type: neutral_display, taxon_name: source_globi_name,
            taxon_id: nil, asvs_count: nil, common_names: nil }
        ]
      }

      expect(subject(ncbi_id_1)).to eq(expected)
    end

    it 'sorts the interaction by type and name' do
      type1 = InteractionType::NEUTRAL_TYPES.first
      type2 = InteractionType::NEUTRAL_TYPES.second

      create_interaction(type2, source_ncbi_id: 4, target_ncbi_id: 1)
      create_interaction(type1, source_ncbi_id: 2, target_ncbi_id: 1)
      create_interaction(type2, source_ncbi_id: 1, target_ncbi_id: nil)
      create_interaction(type1, source_ncbi_id: 1, target_ncbi_id: 4)
      create_interaction(type2, source_ncbi_id: nil, target_ncbi_id: 1)
      create_interaction(type1, source_ncbi_id: 1, target_ncbi_id: 3)
      create_ncbi_node(name: 'a', taxon_id: 1, ncbi_id: 1, asvs_count: 0)
      create_ncbi_node(name: 'c', taxon_id: 3, ncbi_id: 3, asvs_count: 0)
      create_ncbi_node(name: 'e', taxon_id: 2, ncbi_id: 2, asvs_count: 0)
      create_ncbi_node(name: 'd', taxon_id: 4, ncbi_id: 4, asvs_count: 0)

      expected = {
        active: [],
        passive: [],
        neutral: [
          { type: 'adjacent to', taxon_name: 'c', taxon_id: 3, asvs_count: 0,
            common_names: 'a|b' },
          { type: 'adjacent to', taxon_name: 'd', taxon_id: 4, asvs_count: 0,
            common_names: 'a|b' },
          { type: 'adjacent to', taxon_name: 'e', taxon_id: 2, asvs_count: 0,
            common_names: 'a|b' },
          { type: 'co occurs with', taxon_name: 'd', taxon_id: 4,
            asvs_count: 0, common_names: 'a|b' },
          { type: 'co occurs with', taxon_name: 'source_globi_name',
            taxon_id: nil, asvs_count: nil, common_names: nil },
          { type: 'co occurs with', taxon_name: 'target_globi_name',
            taxon_id: nil, asvs_count: nil, common_names: nil }
        ]
      }

      expect(subject(1)).to eq(expected)
    end

    it "ignores interactions from ncbi taxon that don't match a given id" do
      create_interaction(neutral, source_ncbi_id: ncbi_id_2,
                                  target_ncbi_id: nil)
      create_ncbi_node(name: ncbi_name_1, taxon_id: cal_id_2,
                       ncbi_id: ncbi_id_2, asvs_count: source_asvs_count)

      expected = {
        active: [],
        passive: [],
        neutral: []
      }
      expect(subject(ncbi_id_1)).to eq(expected)
    end

    it 'ignores interactions from non-ncbi taxa' do
      create_interaction(neutral, source_ncbi_id: nil, target_ncbi_id: nil)

      expected = {
        active: [],
        passive: [],
        neutral: []
      }
      expect(subject(ncbi_id_1)).to eq(expected)
    end
  end

  describe '#format_iteraction' do
    def subject(interaction, relationship)
      dummy_class.format_iteraction(interaction, relationship)
    end

    context 'when relationship is source' do
      context 'when only target is ncbi taxon' do
        let!(:globi) do
          create_interaction(neutral, source_ncbi_id: nil,
                                      target_ncbi_id: ncbi_id_2)
        end

        it 'returns the target name and taxon_id' do
          expected = {
            taxon_name: ncbi_name_2,
            taxon_id: cal_id_2,
            type: neutral_display,
            asvs_count: target_asvs_count,
            common_names: 'c|d'
          }
          expect(subject(globi, 'source')).to eq(expected)
        end
      end

      context 'when only source is ncbi taxon' do
        let!(:globi) do
          create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: nil)
        end

        it 'returns the target name and taxon_id' do
          expected = {
            taxon_name: ncbi_name_2,
            taxon_id: cal_id_2,
            type: neutral_display,
            asvs_count: target_asvs_count,
            common_names: 'c|d'
          }
          expect(subject(globi, 'source')).to eq(expected)
        end
      end

      context 'when both source and target are ncbi taxa' do
        let!(:globi) do
          create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: ncbi_id_2)
        end

        it 'returns the target name and taxon_id' do
          expected = {
            taxon_name: ncbi_name_2,
            taxon_id: cal_id_2,
            type: neutral_display,
            asvs_count: target_asvs_count,
            common_names: 'c|d'
          }
          expect(subject(globi, 'source')).to eq(expected)
        end
      end

      it 'returns passive type when passive type is passed in' do
        globi = create_interaction(passive, source_ncbi_id: ncbi_id_1,
                                            target_ncbi_id: ncbi_id_2)

        expect(subject(globi, 'source')[:type]).to eq(passive_display)
      end

      it 'returns active type when active type is passed in' do
        globi = create_interaction(active, source_ncbi_id: ncbi_id_1,
                                           target_ncbi_id: ncbi_id_2)

        expect(subject(globi, 'source')[:type]).to eq(active_display)
      end

      it 'returns neutral type when neutral type is passed in' do
        globi = create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                            target_ncbi_id: ncbi_id_2)

        expect(subject(globi, 'source')[:type]).to eq(neutral_display)
      end
    end

    context 'when relationship is target' do
      context 'when only target is a ncbi taxon' do
        let!(:globi) do
          create_interaction(neutral, source_ncbi_id: nil,
                                      target_ncbi_id: ncbi_id_2)
        end

        it 'returns the source name and taxon_id' do
          expected = {
            taxon_name: ncbi_name_1,
            taxon_id: cal_id_1,
            type: neutral_display,
            asvs_count: source_asvs_count,
            common_names: 'a|b'
          }
          expect(subject(globi, 'target')).to eq(expected)
        end
      end

      context 'when only source is a ncbi taxon' do
        let!(:globi) do
          create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: nil)
        end

        it 'returns the source name and taxon_id' do
          expected = {
            taxon_name: ncbi_name_1,
            taxon_id: cal_id_1,
            type: neutral_display,
            asvs_count: source_asvs_count,
            common_names: 'a|b'
          }
          expect(subject(globi, 'target')).to eq(expected)
        end
      end

      context 'when both source and target are ncbi taxa' do
        let!(:globi) do
          create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                      target_ncbi_id: ncbi_id_2)
        end

        it 'returns the source name and taxon_id' do
          expected = {
            taxon_name: ncbi_name_1,
            taxon_id: cal_id_1,
            type: neutral_display,
            asvs_count: source_asvs_count,
            common_names: 'a|b'
          }
          expect(subject(globi, 'target')).to eq(expected)
        end
      end

      it 'returns active type when passive type is passed in' do
        globi = create_interaction(passive, source_ncbi_id: ncbi_id_1,
                                            target_ncbi_id: ncbi_id_2)

        expect(subject(globi, 'target')[:type]).to eq(active_display)
      end

      it 'returns passive type when active type is paased' do
        globi = create_interaction(active, source_ncbi_id: ncbi_id_1,
                                           target_ncbi_id: ncbi_id_2)

        expect(subject(globi, 'target')[:type]).to eq(passive_display)
      end

      it 'returns neutral type when  neutral type is paased in' do
        globi = create_interaction(neutral, source_ncbi_id: ncbi_id_1,
                                            target_ncbi_id: ncbi_id_2)

        expect(subject(globi, 'target')[:type]).to eq(neutral_display)
      end
    end
  end

  describe '#add_ncbi_gbif_ids' do
    def subject(globi, ids, type)
      dummy_class.add_ncbi_gbif_ids(globi, ids, type)
    end

    it 'adds source_ncbi_id and source_gbif_id if NCBI and GBIF ids exists' do
      source_ncbi_ids = 'EOL:1|NCBI:10|WORMS:3|GBIF:30'
      target_ncbi_ids = 'EOL:2|NCBI:20|WORMS:4|GBIF:40'
      globi = create(:globi_interaction,
                     targetTaxonIds: source_ncbi_ids,
                     sourceTaxonIds: target_ncbi_ids)

      expect { subject(globi, source_ncbi_ids, :source) }
        .to change { globi.source_ncbi_id }
        .from(nil).to(10)
        .and change { globi.source_gbif_id }
        .from(nil).to(30)
    end

    it 'adds targets_ncbi_id and targets_gbif_id if NCBI and GBIF ids exists' do
      source_ids = 'EOL:1|NCBI:10|WORMS:3|GBIF:30'
      target_ncbi_ids = 'EOL:2|NCBI:20|WORMS:4|GBIF:40'
      globi = create(:globi_interaction,
                     targetTaxonIds: source_ids,
                     sourceTaxonIds: target_ncbi_ids)

      expect { subject(globi, target_ncbi_ids, :target) }
        .to change { globi.target_ncbi_id }
        .from(nil).to(20)
        .and change { globi.target_gbif_id }
        .from(nil).to(40)
    end

    it 'adds source id if NCBI or GBIF ids exists' do
      source_ids = 'EOL:1|WORMS:3|GBIF:30'
      target_ncbi_ids = 'EOL:2|NCBI:20|WORMS:4'
      globi = create(:globi_interaction,
                     targetTaxonIds: source_ids,
                     sourceTaxonIds: target_ncbi_ids)

      subject(globi, source_ids, :source)

      expect(globi.source_ncbi_id).to eq(nil)
      expect(globi.source_gbif_id).to eq(30)
    end

    it 'adds target id if NCBI or GBIF ids exists' do
      source_ids = 'EOL:1|WORMS:3|GBIF:30'
      target_ncbi_ids = 'EOL:2|NCBI:20|WORMS:4'
      globi = create(:globi_interaction,
                     targetTaxonIds: source_ids,
                     sourceTaxonIds: target_ncbi_ids)

      subject(globi, target_ncbi_ids, :target)
      expect(globi.target_ncbi_id).to eq(20)
      expect(globi.target_gbif_id).to eq(nil)
    end

    it 'does not change source ids if ncbi and gbif ids are absent' do
      source_ids = 'EOL:1|WORMS:3'
      target_ncbi_ids = 'EOL:2|WORMS:4'
      globi = create(:globi_interaction,
                     targetTaxonIds: source_ids,
                     sourceTaxonIds: target_ncbi_ids)

      subject(globi, source_ids, :source)
      expect(globi.source_ncbi_id).to eq(nil)
      expect(globi.source_gbif_id).to eq(nil)
    end

    it 'does not change target ids if ncbi and gbif ids are absent' do
      source_ids = 'EOL:1|WORMS:3'
      target_ncbi_ids = 'EOL:2|WORMS:4'
      globi = create(:globi_interaction,
                     targetTaxonIds: source_ids,
                     sourceTaxonIds: target_ncbi_ids)

      subject(globi, target_ncbi_ids, :target)
      expect(globi.source_ncbi_id).to eq(nil)
      expect(globi.source_gbif_id).to eq(nil)
    end
  end
end
