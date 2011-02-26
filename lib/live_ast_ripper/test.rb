
#
# Used by the LiveAST test suite.
#
module LiveASTRipper::Test
  #
  # no_arg_def(:f, "A#f") returns the ast of
  #
  #   def f
  #     "A#f"
  #   end
  #
  def no_arg_def(name, ret)
    [:def,
     [:@ident, name.to_s],
     [:params, nil, nil, nil, nil, nil],
     [:bodystmt,
      [[:string_literal,
        [:string_content, [:@tstring_content, ret]]]],
      nil,
      nil,
      nil]]
  end

  #
  # no_arg_def_return(no_arg_def(:f, "A#f")) == "A#f"
  #
  def no_arg_def_return(ast)
    ast[3][1][0][1][1][1]
  end

  #
  # binop_def(:f, :+) returns the ast of
  #
  #   def f(x, y)
  #     x + y
  #   end
  #
  def binop_def(name, op)
    [:def,
     [:@ident, name.to_s],
     [:paren,
      [:params,
       [[:@ident, "x"], [:@ident, "y"]],
       nil,
       nil,
       nil,
       nil]],
     [:bodystmt,
      [[:binary,
        [:var_ref, [:@ident, "x"]],
        op,
        [:var_ref, [:@ident, "y"]]]],
      nil,
      nil,
      nil]]
  end

  #
  # binop_define_method(:f, :*) returns the ast of
  #
  #   define_method :f do |x, y|
  #     x * y
  #   end
  #
  # binop_define_method(:f, :-, :my_def) returns the ast of
  #
  #   my_def :f do |x, y|
  #     x - y
  #   end
  #
  def binop_define_method(name, op, using = :define_method)
    [:method_add_block,
     [:command,
      [:@ident, using.to_s],
      [:args_add_block,
       [[:symbol_literal, [:symbol, [:@ident, name.to_s]]]],
       false]],
     [:block,
      [:block_var,
       [:params,
        [[:@ident, "x"], [:@ident, "y"]],
        nil,
        nil,
        nil,
        nil],
       nil],
      [[:binary,
        [:var_ref, [:@ident, "x"]],
        op,
        [:var_ref, [:@ident, "y"]]]]]]
  end

  #
  # binop_define_method_with_var(:method_name, :/) returns the ast of
  #
  #   define_method method_name do |x, y|
  #     x / y
  #   end
  #
  def binop_define_method_with_var(name, op)
    [:method_add_block,
     [:command,
      [:@ident, "define_method"],
      [:args_add_block,
       [[:var_ref, [:@ident, name.to_s]]],
       false]],
     [:block,
      [:block_var,
       [:params,
        [[:@ident, "x"], [:@ident, "y"]],
        nil,
        nil,
        nil,
        nil],
       nil],
      [[:binary,
        [:var_ref, [:@ident, "x"]],
        op,
        [:var_ref, [:@ident, "y"]]]]]]
  end

  #
  # binop_define_singleton_method(:f, :+, :a) returns the ast of
  #
  #   a.define_singleton_method :f do |x, y|
  #     x + y
  #   end
  #
  def binop_define_singleton_method(name, op, receiver)
    [:method_add_block,
     [:command_call,
      [:var_ref, [:@ident, receiver.to_s]],
      :".",
      [:@ident, "define_singleton_method"],
      [:args_add_block,
       [[:symbol_literal, [:symbol, [:@ident, name.to_s]]]],
       false]],
     [:block,
      [:block_var,
       [:params,
        [[:@ident, "x"], [:@ident, "y"]],
        nil,
        nil,
        nil,
        nil],
       nil],
      [[:binary,
        [:var_ref, [:@ident, "x"]],
        op,
        [:var_ref, [:@ident, "y"]]]]]]
  end
  
  #
  # no_arg_block(:foo, "bar") returns the ast of
  #
  #   foo { "bar" }
  #
  def no_arg_block(name, ret)
    [:method_add_block,
     [:method_add_arg, [:fcall, [:@ident, name.to_s]], []],
     [:block,
      nil,
      [[:string_literal,
        [:string_content, [:@tstring_content, ret.to_s]]]]]]
  end
  
  #
  # binop_block(:foo, :+) returns the ast of
  #
  #   foo { |x, y| x + y }
  #
  def binop_block(name, op)
    [:method_add_block,
     [:method_add_arg, [:fcall, [:@ident, name.to_s]], []],
     [:block,
      [:block_var,
       [:params,
        [[:@ident, "x"], [:@ident, "y"]],
        nil,
        nil,
        nil,
        nil],
       nil],
      [[:binary,
        [:var_ref, [:@ident, "x"]],
        op,
        [:var_ref, [:@ident, "y"]]]]]]
  end

  #
  # binop_proc_new(:*) returns the ast of
  #
  #   Proc.new { |x, y| x * y }
  #
  def binop_proc_new(op)
    [:method_add_block,
     [:call,
      [:var_ref, [:@const, "Proc"]],
      :".",
      [:@ident, "new"]],
     [:block,
      [:block_var,
       [:params,
        [[:@ident, "x"], [:@ident, "y"]],
        nil,
        nil,
        nil,
        nil],
       nil],
      [[:binary,
        [:var_ref, [:@ident, "x"]],
        op,
        [:var_ref, [:@ident, "y"]]]]]]
  end
end

#
# testing assumes sexps are steamrolled
#
LiveASTRipper.steamroll = true
