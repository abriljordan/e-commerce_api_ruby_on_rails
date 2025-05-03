class ApplicationSerializer < ActiveModel::Serializer
  def attributes(*args)
    hash = super
    hash.each do |key, value|
      hash[key] = value.iso8601 if value.respond_to?(:iso8601)
    end
    hash
  end
end 