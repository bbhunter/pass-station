# frozen_string_literal: true

# Pass Station module
module PassStation
  # Password database handling
  class DB
    # Search term in the data table
    # @param term [String] the searched term
    # @param col [Symbol] the column to search in: :productvendor | :username | :password | :all (all columns)
    # @see build_regexp for +opts+ param description
    # @return [Array<CSV::Row>] table of +CSV::Row+, each row contains three
    #   attributes: :productvendor, :username, :password
    def search(term, col, opts = {})
      r1 = prepare_search(term, opts)
      condition = column_selector(col, r1)
      @data.each do |row|
        @search_result.push(row) if condition.call(row)
      end
      @search_result
    end

    # Choose in which column the search will be performed and build the
    # condition to use
    # @param col [Symbol] the column to search in: :productvendor | :username | :password | :all (all columns)
    # @param rgxp [Regexp] the search regexp (generated by {build_regexp})
    # @return [Proc] the proc condition to use for searching
    def column_selector(col, rgxp)
      proc { |row|
        if col == :all
          row[:productvendor].match?(rgxp) || row[:username].match?(rgxp) ||
            row[:password].match?(rgxp)
        else
          row[col].match?(rgxp)
        end
      }
    end

    # Prepare search query
    # Check if data available, prepare the regexp, and clean previous search
    # results
    # @see build_regexp for parameters and return value
    def prepare_search(term, opts = {})
      data_nil?
      r1 = build_regexp(term, opts)
      @search_result = []
      r1
    end

    # Manage search options to build a search regexp
    # @param term [String] the searched term
    # @param opts [Hash] the option hash
    # @option opts [Boolean] :sensitive is the search case sensitive, default: false
    # @return [Regexp] the search regexp
    def build_regexp(term, opts = {})
      opts[:sensitive] ||= false
      if opts[:sensitive]
        Regexp.new(term, Regexp::EXTENDED)
      else
        Regexp.new(term, Regexp::EXTENDED | Regexp::IGNORECASE)
      end
    end

    # Raise an error is data attribute is nil
    def data_nil?
      raise 'You must use the parse method to polutate the data attribute first' if @data.nil?
    end

    protected :build_regexp, :prepare_search, :column_selector, :data_nil?
  end
end
