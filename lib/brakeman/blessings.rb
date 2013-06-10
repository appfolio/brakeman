require 'digest/md5'
require 'singleton'

class Brakeman::Blessings
  include Singleton

  WHOLE_LINE_COMMENTS = {
    :ruby => /^\s*#(.+)$/,
    :haml => /<%#([^%>]+)%>$/,
    :erb => /<%#([^%>]+)%>/
  }.freeze
  HASH_IN_COMMENT = /(?:^|\W)([a-z0-9]{32})(?:\W|$)/

  def initialize
    @blessing_hash = {}
  end

  def is_blessed?(result)
    hash = hash_result(result)
    !!@blessing_hash[hash]
  end

  def hash_result(result)
    Digest::MD5.hexdigest("#{result.class}\n#{result.code.to_s}\n#{result.check.sub /^Brakeman::/, ''}")
  end

  def add_blessing(blessing_hash)
    @blessing_hash[blessing_hash] = true
  end

  def parse_string_for_blessings(string, language = :ruby)
    comments = string.scan WHOLE_LINE_COMMENTS[language]
    comments.each do |comment|
      comment[0].scan(HASH_IN_COMMENT) do |hash|
        add_blessing hash[0].strip
      end
    end
  end
end