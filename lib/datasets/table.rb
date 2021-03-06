require "datasets/dictionary"

module Datasets
  class Table
    include Enumerable

    def initialize(dataset)
      @dataset = dataset
    end

    def each(&block)
      columner_data.each(&block)
    end

    def [](name)
      columner_data[name.to_sym]
    end

    def dictionary_encode(name)
      Dictionary.new(self[name])
    end

    def label_encode(name)
      dictionary = dictionary_encode(name)
      self[name].collect do |value|
        dictionary.id(value)
      end
    end

    def fetch_values(*keys)
      data = columner_data
      keys.collect do |key|
        if data.key?(key)
          data[key]
        else
          raise build_key_error(key) unless block_given?
          yield(key)
        end
      end
    end

    def to_h
      columns = {}
      @dataset.each do |record|
        record.to_h.each do |name, value|
          values = (columns[name] ||= [])
          values << value
        end
      end
      columns
    end

    private
    begin
      KeyError.new("message", receiver: self, key: :key)
    rescue ArgumentError
      def build_key_error(key)
        KeyError.new("key not found: #{key.inspect}")
      end
    else
      def build_key_error(key)
        KeyError.new("key not found: #{key.inspect}",
                     receiver: self,
                     key: key)
      end
    end

    def columner_data
      @columns ||= to_h
    end
  end
end
