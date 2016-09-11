class Dispatch::BaseSerializer < ActiveModel::Serializer
  def serializable_hash
    generated_hash = super || {}
    params_hash = object.try(:params)
    params_hash ||= object.try(:data)
    params_hash ||= {}

    params_hash.deep_merge(generated_hash)
  end
end
