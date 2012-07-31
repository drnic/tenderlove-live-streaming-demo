require 'active_record/associations/builder/association'
require 'active_support/core_ext/module/aliasing'
require 'active_support/deprecation'

module ActiveRecord::Associations::Builder
  class DeprecatedOptionsProc
    attr_reader :options

    def initialize(options)
      options[:includes]  = options.delete(:include)    if options[:include]
      options[:where]     = options.delete(:conditions) if options[:conditions]
      options[:extending] = options.delete(:extend)     if options[:extend]

      @options = options
    end

    def to_proc
      options = self.options
      proc do |owner|
        if options[:where].respond_to?(:to_proc)
          context = owner || self
          where(context.instance_eval(&options[:where]))
            .merge!(options.except(:where))
        else
          merge(options)
        end
      end
    end

    def arity
      1
    end
  end

  class Association
    DEPRECATED_OPTIONS = [:readonly, :order, :limit, :group, :having,
                          :offset, :select, :uniq, :include, :conditions, :extend]

    self.valid_options += [:select, :conditions, :include, :extend, :readonly]

    def initialize_with_deprecated_options(model, name, scope, options)
      if scope.is_a?(Hash)
        options            = scope
        deprecated_options = options.slice(*DEPRECATED_OPTIONS)

        if deprecated_options.empty?
          scope = nil
        else
          ActiveSupport::Deprecation.warn(
            "The following options in your #{model.name}.#{macro} :#{name} declaration are deprecated: " \
            "#{deprecated_options.keys.map(&:inspect).join(',')}. Please use a scope block instead. " \
            "For example, the following:\n" \
            "\n" \
            "    has_many :spam_comments, conditions: { spam: true }, class_name: 'Comment'\n" \
            "\n" \
            "should be rewritten as the following:\n" \
            "\n" \
            "    has_many :spam_comments, -> { where spam: true }, class_name: 'Comment'\n"
          )
          scope   = DeprecatedOptionsProc.new(deprecated_options)
          options = options.except(*DEPRECATED_OPTIONS)
        end
      end

      initialize_without_deprecated_options(model, name, scope, options)
    end

    alias_method_chain :initialize, :deprecated_options
  end

  class CollectionAssociation
    include Module.new {
      def valid_options
        super + [:order, :group, :having, :limit, :offset, :uniq]
      end
    }
  end
end
