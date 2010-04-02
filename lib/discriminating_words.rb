module DiscriminatingWords
  def self.find_discriminating_words(content, options={})
    default_options = {:message => 'include assault words',
                       :with => "arse, arsehole, asshole, bastard, bitch, bloody, bollocks, crap, cunt, damn, dick, dickhead, fuck, fucking, motherfucker, nigger, paki, pissed, prick, shag, shit, slag, sodding, spastic, suck, sucking, twat, wanker, whore"}
    options.merge!(default_options) {|key, old, new| old}
    new_reqexp_string = ""
    options[:with].gsub(/\s/, "").split(",").each do |word|
      new_reqexp_string << '\W' + word + '\W|^' + word + '\W|\W' + word + '$|^' + word + '$|'
    end
    content.match(Regexp.new("(#{new_reqexp_string.chop})", Regexp::IGNORECASE)) ? [ options[:message] ] : nil
  end
end

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_discriminating_words_of(*attr_names)
        options = {:on => :save}
        options.update(attr_names.pop) if attr_names.last.is_a?(Hash)
        validates_each(attr_names, options) do |record, attr_name, value|
          v = value.to_s
          errors = DiscriminatingWords::find_discriminating_words(v, options)
          errors.each do |error|
            record.errors.add(attr_name, error)
          end unless errors.nil?
        end
      end
    end
  end
end