module ActiveModel
  class Serializer
    module CanCan
      module HasOne
        def serialize
          unless authorize?
            return super
          end
          object = associated_object
          serializer = find_serializable(object)
          if serializer && serializer.can?(:read, object)
            super
          else
            nil
          end
        end
      end
    end
  end
end
