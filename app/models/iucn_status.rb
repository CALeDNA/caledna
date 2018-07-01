# frozen_string_literal: true

class IucnStatus
  CATEGORIES = {
    EX: 'extinct',
    EW: 'extinct in the wild',
    CR: 'critically endangered',
    EN: 'endangered',
    VU: 'vulnerable',
    NT: 'near threatened',
    LC: 'least concern',
    DD: 'data deficient',
    NE: 'not evaluated'
  }.freeze

  THREATENED = {
    EX: 'extinct',
    EW: 'extinct in the wild',
    CR: 'critically endangered',
    EN: 'endangered',
    VU: 'vulnerable',
    NT: 'near threatened'
  }.freeze
end