require 'ripper'

module LiveAST
  class Parser
    class << self
      #
      # Whether to strip line/column and other personality traits.
      #
      # This is Ripper-specific -- not part of the live_ast API.
      #
      attr_accessor :steamroll
    end
    
    # Output an AST corresponding to a ruby source string.
    def parse(code)
      @defs = {}
      process(Ripper.sexp(code))
      @defs
    end

    def process(sexp)
      case sexp[0]
      when :def
        process_def(sexp)
      when :method_add_block
        process_method_add_block(sexp)
      else
        sexp.map { |elem|
          elem.is_a?(Array) ? process(elem) : elem
        }
      end
    end
    
    def process_def(sexp)
      line = sexp[1][2][0]

      result = []
      result << sexp.shift
      result << sexp.shift
      result << process(sexp.shift)
      result << process(sexp.shift)

      result = steamroll(result) if Parser.steamroll
      store_sexp(result, line)

      []
    end

    def process_method_add_block(sexp)
      line = 
        case sexp[1][0]
        when :method_add_arg
          sexp[1][1][1].last[0]
        when :call, :command_call
          sexp[1][3][2][0]
        when :command
          sexp[1][1][2][0]
        end

      result = []
      result << sexp.shift
      result << process(sexp.shift)
      result << process(sexp.shift)
        
      result = steamroll(result) if Parser.steamroll
      store_sexp(result, line)

      []
    end

    def store_sexp(sexp, line)
      @defs[line] = @defs.has_key?(line) ? :multiple : sexp
    end

    def steamroll(sexp)
      sexp.map { |elem|
        if elem.is_a? Array
          sub_elem = 
            if elem[0].is_a?(Symbol) and elem[0][0] == "@"
              elem[0..-2]
            else
              elem
            end
          steamroll(sub_elem)
        elsif elem == :brace_block or elem == :do_block
          :block
        else
          elem
        end
      }
    end
  end
end

LiveAST::Parser.autoload :TestForms, "live_ast_ripper/test_forms"
