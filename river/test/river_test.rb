# frozen_string_literal: true

require 'test_helper'

module River
  class Test < ActiveSupport::TestCase
    test 'truth' do
      assert_kind_of Module, River
    end
  end
end
