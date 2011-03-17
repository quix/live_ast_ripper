require 'live_ast/base'
require 'ripper'

#
# Ripper-based parser plugin for LiveAST.
#
class LiveASTRipper
  #
  # Returns a line-to-AST hash where the AST corresponds to the method
  # or block defined at the given line.
  #
  # This method is the only requirement of a LiveAST parser plugin.
  #
  def parse(code)
    @defs = {}
    process(Ripper.sexp(code))
    @defs
  end

  def process(sexp)  #:nodoc:
    line = line_of(sexp) and
      @defs[line] = @defs.has_key?(line) ? :multiple : sexp

    LiveASTRipper.steamroll_toplevel(sexp) if LiveASTRipper.steamroll

    sexp.each do |elem|
      process(elem) if elem.is_a? Array
    end
  end

  def line_of(sexp)  #:nodoc:
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
  end

  class << self
    def steamroll_toplevel(sexp)  #:nodoc:
      # remove [line, column]
      if sexp.first.is_a?(Symbol) and sexp.first[0] == "@"
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

    #
    # Destructive operation on +ast+:
    #
    # * remove [line, column] pairs
    # * change +:brace_block+ and +:do_block+ to +:block+
    #
    def steamroll_ast(ast)
      steamroll_toplevel(ast)
      ast.each do |elem|
        steamroll_ast(elem) if elem.is_a? Array
      end
      ast
    end

    #
    # When true-valued, steamroll all ASTs created by the parser.
    # Default is +false+. (Although referencing
    # <code>LiveASTRipper::Test</code> will set it to +true+.)
    #
    attr_accessor :steamroll
  end
end

LiveASTRipper.autoload :Test, "live_ast_ripper/test"

LiveAST.parser = LiveASTRipper
