# frozen_string_literal: true

class InteractionType
  TYPES = {
    'adjacentTo': 'adjacentTo',

    'coOccursWith': 'coOccursWith',

    'createsHabitatFor': 'isHabitatOf',
    'isHabitatOf': 'createsHabitatFor',

    'damagedBy': 'damages',
    'damages': 'damagedBy',

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

    'farmedBy': 'farms',
    'farms': 'farmedBy',

    'flowersVisitedBy': 'visitsFlowersOf',
    'visitsFlowersOf': 'flowersVisitedBy',

    'guestOf': 'hasGuestOf',
    'hasGuestOf': 'guestOf',

    'hostOf': 'hasHost',
    'hasHost': 'hostOf',

    'hyperparasiteOf': 'hasHyperparasite',
    'hasHyperparasite': 'hyperparasiteOf',

    'hyperparasitoidOf': 'hasHyperparasitoid',
    'hasHyperparasitoid': 'hyperparasitoidOf',

    'inhabitedBy': 'inhabits',
    'inhabits': 'inhabitedBy',

    'interactsWith': 'interactsWith',

    'kills': 'killedBy',
    'killedBy': 'kills',

    'kleptoparasiteOf': 'hasKleptoparasite',
    'hasKleptoparasite': 'kleptoparasiteOf',

    'laysEggsOn': 'hasEggsLayedOnBy',
    'hasEggsLayedOnBy': 'laysEggsOn',

    'livedInsideOfBy': 'livesInsideOf',
    'livesInsideOf': 'livedInsideOfBy',

    'livedNearBy': 'livesNear',
    'livesNear': 'livedNearBy',

    'livedOnBy': 'livesOn',
    'livesOn': 'livedOnBy',

    'livedUnderBy': 'livesUnder',
    'livesUnder': 'livedUnderBy',

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
