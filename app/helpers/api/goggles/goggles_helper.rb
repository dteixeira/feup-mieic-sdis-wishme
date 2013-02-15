require 'net/http'
require 'uri'
require 'base64'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module Api::Goggles::GogglesHelper

  # Container class for Goggles response messages
  class GogglesMessage
    attr_accessor :message, :type

    def initializer (type = nil, message = nil)
      @type = type
      @message = message
    end

  end

  # This class is used to parse Googles' proprietary 
  # "Protocol Buffer" message format
  class GogglesParser
    
    # Protocol Buffer special characters
    LINE_FEED = 0x10
    END_FLAG = 0x077D340A
    SPACE = 0x20
    PRE_END_FLAG_1 = 0x2A
    PRE_END_FLAG_2 = 0x00

    # Protocol Buffer wire types
    WIRE_VARINT = 0x00
    WIRE_FIXED_64 = 0x01
    WIRE_DELIMITED = 0x02
    WIRE_START_GROUP = 0x03
    WIRE_END_GROUP = 0x04
    WIRE_FIXED_32 = 0x05
    WIRE_TYPE_MASK = 0x07
    VARINT_MASK = 0x7F
    EMPTY_RESPONSE = [ 0x49, 0x54, 0x41, 0x54, 0x20, 0x54,
                      0xEF, 0xBF, 0x84, 0xEF, 0xBE, 0xB0, 
                      0x54, 0x20 ].pack 'c*'

    # Converts an integer (32-bit) to a varint representation
    # Returns array of bytes
    def self.int_to_varint_32 (value)
      varint = [] 
      while (i = VARINT_MASK & value) != 0 do
        value = value >> 7
        i += 128 if VARINT_MASK & value != 0
        varint.push i
      end
      varint
    end

    # Consumes and parses a varint from the buffer
    # Returns 0 if buffer is nil or empty
    def self.parse_varint! buffer
      value = 0
      for i in 0..buffer.index { |e| e >> 7 == 0 } do
        value = value | (buffer.delete_at(0) & VARINT_MASK) << 7 * i
      end if buffer && !buffer.empty?
      value
    end

    # Parses a varint from the buffer
    # Returns 0 if buffer is nil or empty
    def self.parse_varint buffer
      value = 0
      for i in 0..buffer.index { |e| e >> 7 == 0 } do
        value = value | (buffer[i] & VARINT_MASK) << 7 * i
      end if buffer && !buffer.empty?
      value
    end

    # Consumes and parses a string from the buffer
    # Returns nil if buffer is nil or empety
    # Returns '' if string has length of 0
    def self.parse_string! buffer
      (buffer.shift parse_varint! buffer).pack 'c*' if buffer && !buffer.empty?
    end

    # Parses the response from a Protocol Buffer
    # Returns an array of GogglesMessage with results
    # Empty array means no results for given image
    def self.parse_response response
      # Eliminate unwanted data and fix the similar
      # image message problem
      result = []
      buffer = response.unpack 'c*'
      buffer.shift
      parse_varint! buffer
      sim_image_fix = check_response_end buffer
      buffer.shift

      while !buffer.empty? && !sim_image_fix do
        # Parse message
        message = GogglesMessage.new
        if parse_varint!(buffer) != END_FLAG
          buffer.shift
          message.message = parse_string! buffer 
        else break end

        # Parse type
        if parse_varint!(buffer) != END_FLAG
          message.type = parse_string! buffer 
        else break end

        # Accept response or stop on invalid content
        break if message.message == EMPTY_RESPONSE
        result.push message
        break if check_response_end buffer
        buffer.shift
      end
      result
    end

    # Checks if the the end of parsable content
    # has been reached
    def self.check_response_end buffer
      res = false
      if buffer[0] == PRE_END_FLAG_1 && buffer[1] == PRE_END_FLAG_2
        temp = buffer.shift 2
        res = parse_varint(buffer) == END_FLAG
        buffer.unshift(temp).flatten
      end
      res
    end

  end

  # This class is used to make image recognition
  # request to Google's Goggles
  class GogglesRequest

    # Request definitions
    HTTP_OK = '200'
    GOGGLES_REQUEST_URL = 'https://www.google.com/goggles/container_proto?cssid='
    GOGGLES_REQUEST_CONTENT_TYPE = 'application/x-protobuffer'
    GOGGLES_REQUEST_PRAGMA = 'no-cache'
    TRAILING_BYTES = [ 0x18, 0x4B, 0x20, 0x01, 0x30, 0x00, 
                      0x92, 0xEC, 0xF4, 0x3B, 0x09, 0x18, 
                      0x00, 0x38, 0xC6, 0x97, 0xDC, 0xDF,
                      0xF7, 0x25, 0x22, 0x00 ].pack 'c*'

    # Sends a image recognition request to Goggles
    # 'image' is the binary representation of the image file
    def self.make_request image
      uri = URI(GOGGLES_REQUEST_URL)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
        request = Net::HTTP::Post.new uri.request_uri
        request['Content-Type'] = GOGGLES_REQUEST_CONTENT_TYPE
        request['Pragma'] = GOGGLES_REQUEST_PRAGMA
        request.body = build_post_data image 
        response = https.request request
        https.finish
        response.body if response.code == HTTP_OK
      end if image
    end

    # Reads a binary file
    def self.read_file filename
      File.open(filename, 'rb').read if filename && File.exists?(filename)
    end

    # Decodes a Base64 encoded string
    def self.decode_base64 encoded
      Base64.decode64 encoded if encoded
    end

    # Makes an image recognition request to Goggles and returns
    # the parsed response
    def self.lookup_image image
      image = decode_base64(image.gsub('\n', '').gsub('\r', ''))
      if response = make_request(image)
        GogglesParser.parse_response response
      end
    end

    # Builds the post body to send to Goggles
    def self.build_post_data image
      x = image.length
      s = ''
      [32, 14, 10, 0].each do |y|
        s += [10].pack('c') + GogglesParser.int_to_varint_32(x + y).pack('c*')
      end
      s += image + TRAILING_BYTES
    end

  end

end
