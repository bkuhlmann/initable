# frozen_string_literal: true

require "marameters"

module Initable
  # Builds initialization behavior.
  # :reek:TooManyInstanceVariables
  class Builder < Module
    def initialize *parameters, scope: :private, marameters: Marameters
      super()

      @parameters = marameters.for parameters
      @scope = scope
      @marameters = marameters
      @names = @parameters.names.compact
      @instance_module = Module.new.set_temporary_name "initable"

      freeze
    end

    def included descendant
      super
      define_initialize descendant
      descendant.include instance_module
    end

    private

    attr_reader :scope, :parameters, :marameters, :names, :instance_module

    def define_initialize descendant,
                          inheritor: Marameters::Signatures::Inheritor.new,
                          forwarder: Marameters::Signatures::Super.new
      ancestor = marameters.of(descendant, :initialize).first
      signature = inheritor.call(ancestor, parameters).then { |params| marameters.signature params }

      instance_module.module_eval <<-METHOD, __FILE__, __LINE__ + 1
        def initialize(#{signature})
          #{build_instance_variables ancestor}
          super(#{forwarder.call ancestor, parameters})
        end
      METHOD

      define_readers ancestor
    end

    def build_instance_variables ancestor
      (names - ancestor.names).map { |name| "@#{name} = #{name}" }
                              .join "\n"
    end

    def define_readers ancestor
      instance_module.module_eval <<-READERS, __FILE__, __LINE__ + 1
        #{compute_scope} attr_reader(*#{names - ancestor.names})
      READERS
    end

    def compute_scope = METHOD_SCOPES.include?(scope) ? scope : :private
  end
end
