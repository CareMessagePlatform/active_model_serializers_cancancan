module ActiveModel
  class Serializer
    module CanCan
      module Helpers
        def current_ability
          Ability.new(instance_options[:scope])
        end

        def current_user
          instance_options[:scope]
        end

        def can?(*args)
          current_ability.can? *args
        end

        def cannot?(*args)
          current_ability.cannot? *args
        end
      end
    end
  end
end

ActiveModel::Serializer.send :include, ActiveModel::Serializer::CanCan::Helpers
