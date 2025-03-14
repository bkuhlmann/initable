# frozen_string_literal: true

require "initable/builder"

# Main namespace.
module Initable
  METHOD_SCOPES = %i[public protected private].freeze

  def self.[](*, **) = Builder.new(*, **)

  def self.protected(*, **) = Builder.new(*, scope: __method__, **)

  def self.public(*, **) = Builder.new(*, scope: __method__, **)
end
