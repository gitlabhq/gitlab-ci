class Extension
  def self.deep_merge(hash, other_hash, &block)
    deep_merge!(hash.dup, other_hash, &block)
  end

  # Same as +deep_merge+, but modifies +self+.
  def self.deep_merge!(hash, other_hash, &block)
    other_hash.each_pair do |k,v|
      tv = hash[k]
      if tv.is_a?(Hash) && v.is_a?(Hash)
        hash[k] = deep_merge(tv, v, &block)
      else
        hash[k] = block && tv ? block.call(k, tv, v) : v
      end
    end
    hash
  end
end