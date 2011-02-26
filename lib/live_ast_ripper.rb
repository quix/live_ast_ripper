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
    line =
      case sexp.first
      when :def
        sexp[1][2][0]
      when :method_add_block
        case sexp[1][0]
        when :method_add_arg
          sexp[1][1][1].last[0]
        when :call, :command_call
          sexp[1][3][2][0]
        when :command
          sexp[1][1][2][0]
        end
      end

    if line
      @defs[line] = @defs.has_key?(line) ? :multiple : sexp
    end

    steamroll(sexp) if LiveASTRipper.steamroll

    sexp.each do |elem|
      process(elem) if elem.is_a? Array
    end
  end

  def steamroll(sexp)
    if sexp.first.is_a?(Symbol) and sexp.first[0] == "@"
      # remove [line, column]
      sexp.pop
    end
    
    sexp.map! { |elem|
      case elem
      when :brace_block, :do_block
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
