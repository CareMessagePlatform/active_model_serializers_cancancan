module ActiveModel
  class Serializer
    module CanCan
      module HasMany
        def serialize
          return super unless authorize?
          associated_object.select {|item| find_serializable(item).can?(:read, item) }.map do |item|
            find_serializable(item).serializable_hash
          end
        end
      end
    end
  end
end
