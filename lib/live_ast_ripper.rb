require 'live_ast/base'
require 'ripper'

#
# Ripper-based parser plugin for LiveAST.
#
class LiveASTRipper
  VERSION = "0.6.0"

  #
  # Returns a line-to-sexp hash where sexp corresponds to the method
  # or block defined at the given line.
  #
  # This method is the only requirement of a LiveAST parser plugin.
  #
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

    store_sexp(result, line)
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
    
    store_sexp(result, line)
  end

  def store_sexp(sexp, line)
    @defs[line] = 
      if @defs.has_key?(line)
        :multiple
      elsif LiveASTRipper.steamroll
        steamroll(sexp)
      else
        sexp
      end

    sexp
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

  class << self
    #
    # Whether to strip line/column and other personality traits.
    #
    attr_accessor :steamroll
  end
end

LiveASTRipper.autoload :Test, "live_ast_ripper/test"

LiveAST.parser = LiveASTRipper
