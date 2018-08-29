module ActiveModel
  class Serializer
    module Associations
      class Config
        def authorize?
          !!options[:authorize]
        end
      end

      class HasMany
        prepend ActiveModel::Serializer::CanCan::HasMany
      end

      class HasOne
        prepend ActiveModel::Serializer::CanCan::HasOne
      end
    end
  end
end

