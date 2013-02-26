require 'charlock_holmes/string'

module GitlabCi
  module Encode
    extend self

    def encode!(message)
      return nil unless message.respond_to? :force_encoding

      # if message is utf-8 encoding, just return it
      message.force_encoding("UTF-8")
      return message if message.valid_encoding?

      # return message if message type is binary
      detect = CharlockHolmes::EncodingDetector.detect(message)
      return message if detect[:type] == :binary

      # if message is not utf-8 encoding, convert it
      if detect[:encoding]
        message.force_encoding(detect[:encoding])
        message.encode!("UTF-8", detect[:encoding], undef: :replace, replace: "", invalid: :replace)
      end

      # ensure message encoding is utf8
      message.valid_encoding? ? message : raise

      # Prevent app from crash cause of encoding errors
    rescue
      encoding = detect ? detect[:encoding] : "unknown"
      "--broken encoding: #{encoding}"
    end
  end
end
