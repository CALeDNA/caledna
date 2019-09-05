# frozen_string_literal: true

class InteractionType
  NEUTRAL_TYPES = %w[
    adjacentTo
    coOccursWith
    interactsWith
    livesWith
    symbiontOf
  ].freeze

  ACTIVE_TYPES = %w[
    createsHabitatFor
    damages
    dispersalVectorOf
    eats
    ectoParasiteOf
    ectoParasitoid
    endoparasiteOf
    endoparasitoidOf
    epiphyteOf
    farms
    visitsFlowersOf
    guestOf
    hostOf
    hyperparasiteOf
    hyperparasitoidOf
    inhabits
    kills
    kleptoparasiteOf
    laysEggsOn
    livesInsideOf
    livesNear
    livesOn
    livesUnder
    parasiteOf
    parasitoidOf
    pathogenOf
    perchingOn
    pollinates
    preysOn
    visits
    vectorOf
  ].freeze

  PASSIVE_TYPES = %w[
    isHabitatOf
    damagedBy
    hasDispersalVector
    eatenBy
    hasEctoparasite
    hasEctoparasitoid
    hasEndoparasite
    hasEndoparasitoid
    hasEpiphyte
    farmedBy
    flowersVisitedBy
    hasGuestOf
    hasHost
    hasHyperparasite
    hasHyperparasitoid
    inhabitedBy
    killedBy
    hasKleptoparasite
    hasEggsLayedOnBy
    livedInsideOfBy
    livedNearBy
    livedOnBy
    livedUnderBy
    hasParasite
    hasParasitoid
    hasPathogen
    perchedOnBy
    pollinatedBy
    preyedUponBy
    visitedBy
    hasVector
  ].freeze

  TYPES = {
    'adjacentTo': 'adjacentTo',

    'coOccursWith': 'coOccursWith',

    'createsHabitatFor': 'isHabitatOf',
    'isHabitatOf': 'createsHabitatFor',

    'damages': 'damagedBy',
    'damagedBy': 'damages',

    'dispersalVectorOf': 'hasDispersalVector',
    'hasDispersalVector': 'dispersalVectorOf',

    'eats': 'eatenBy',
    'eatenBy': 'eats',

    'ectoParasiteOf': 'hasEctoparasite',
    'hasEctoparasite': 'ectoParasiteOf',

    'ectoParasitoid': 'hasEctoparasitoid',
    'hasEctoparasitoid': 'ectoParasitoid',

    'endoparasiteOf': 'hasEndoparasite',
    'hasEndoparasite': 'endoparasiteOf',

    'endoparasitoidOf': 'hasEndoparasitoid',
    'hasEndoparasitoid': 'endoparasitoidOf',

    'epiphyteOf': 'hasEpiphyte',
    'hasEpiphyte': 'epiphyteOf',

    'farms': 'farmedBy',
    'farmedBy': 'farms',

    'visitsFlowersOf': 'flowersVisitedBy',
    'flowersVisitedBy': 'visitsFlowersOf',

    'guestOf': 'hasGuestOf',
    'hasGuestOf': 'guestOf',

    'hostOf': 'hasHost',
    'hasHost': 'hostOf',

    'hyperparasiteOf': 'hasHyperparasite',
    'hasHyperparasite': 'hyperparasiteOf',

    'hyperparasitoidOf': 'hasHyperparasitoid',
    'hasHyperparasitoid': 'hyperparasitoidOf',

    'inhabits': 'inhabitedBy',
    'inhabitedBy': 'inhabits',

    'interactsWith': 'interactsWith',

    'kills': 'killedBy',
    'killedBy': 'kills',

    'kleptoparasiteOf': 'hasKleptoparasite',
    'hasKleptoparasite': 'kleptoparasiteOf',

    'laysEggsOn': 'hasEggsLayedOnBy',
    'hasEggsLayedOnBy': 'laysEggsOn',

    'livesInsideOf': 'livedInsideOfBy',
    'livedInsideOfBy': 'livesInsideOf',

    'livesNear': 'livedNearBy',
    'livedNearBy': 'livesNear',

    'livesOn': 'livedOnBy',
    'livedOnBy': 'livesOn',

    'livesUnder': 'livedUnderBy',
    'livedUnderBy': 'livesUnder',

    'livesWith': 'livesWith',

    'parasiteOf': 'hasParasite',
    'hasParasite': 'parasiteOf',

    'parasitoidOf': 'hasParasitoid',
    'hasParasitoid': 'parasitoidOf',

    'pathogenOf': 'hasPathogen',
    'hasPathogen': 'pathogenOf',

    'perchingOn': 'perchedOnBy',
    'perchedOnBy': 'perchingOn',

    'pollinates': 'pollinatedBy',
    'pollinatedBy': 'pollinates',

    'preysOn': 'preyedUponBy',
    'preyedUponBy': 'preysOn',

    'symbiontOf': 'symbiontOf',

    'visits': 'visitedBy',
    'visitedBy': 'visits',

    'vectorOf': 'hasVector',
    'hasVector': 'vectorOf'
  }.freeze
end
