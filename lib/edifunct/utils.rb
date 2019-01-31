module Edifunct::Utils
  def self.stringify_hash_keys!(hash)
    hash.each{ |k,v| hash[k.to_s] = v }
  end
end
