class Extension
  def self.deep_merge(hash, other_hash, &block)
    deep_merge!(hash.dup, other_hash, &block)
  end

  # Same as +deep_merge+, but modifies +self+.
  def self.deep_merge!(hash, other_hash, &block)
    hash.merge!(other_hash) do |k, old, new|
      if block
        block.call(k, old, new)
      elsif old.is_a?(Array) && new.is_a?(Array)
        old + new
      elsif old.is_a?(Hash) && new.is_a?(Hash)
        deep_merge(old, new)
      else
        new
      end
    end
  end



  def self.deep_symbolize_keys(hash)
    hash.inject({}) { |result, (key, value)|
      result[(key.to_sym rescue key) || key] = case value
                                                 when Array
                                                   value.map { |value| value.is_a?(Hash) ? Extension.deep_symbolize_keys(value) : value }
                                                 when Hash
                                                   Extension.deep_symbolize_keys(value)
                                                 else
                                                   value
                                               end
      result
    }
  end

  def self.deep_symbolize_keys!(hash)
    hash.replace(hash.deep_symbolize_keys)
  end
end
