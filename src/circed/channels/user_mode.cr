module Circed
  class UserMode
    VALID_MODES = ["o", "h", "v"]
    MODE_HASH   = {
      "o" => "@",
      "h" => "%",
      "v" => "+",
    }
    SORTED_MODES = VALID_MODES.sort.reverse!

    getter mode : String = ""

    def initialize(mode = "")
      validate_mode(mode) unless mode.empty?
      @mode = mode
    end

    def add(mode)
      validate_mode(mode)
      @mode += mode unless @mode.includes?(mode)
    end

    def remove(mode)
      validate_mode(mode)
      @mode = @mode.delete(mode)
    end

    def highest_mode : String
      SORTED_MODES.each do |mode|
        if @mode.includes?(mode)
          return MODE_HASH[mode]
        end
      end
      ""
    end

    def has_mode?(mode)
      @mode.includes?(mode)
    end

    def has_any_mode?(modes)
      modes.any? { |mode| has_mode?(mode) }
    end

    def has_all_modes?(modes)
      modes.all? { |mode| has_mode?(mode) }
    end

    def is_operator?
      has_mode?("o")
    end

    def is_half_operator?
      has_mode?("h")
    end

    def is_voiced?
      has_mode?("v")
    end

    def to_s(io : IO)
      io << mode
    end

    private def validate_mode(mode)
      unless VALID_MODES.includes?(mode)
        raise Exception.new("Invalid mode: #{mode}")
      end
    end
  end
end
