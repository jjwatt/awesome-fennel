#!/usr/bin/env lua
local fennel = require("fennel")
local function parse_arg()
  local config_path = nil
  local show_checks_3f = false
  local files = {}
  while arg[1] do
    if ("-h" == arg[1]) then
      print("usage: check.fnl [-s] [-c config] file ...")
      os.exit(0)
    elseif ("-s" == arg[1]) then
      show_checks_3f = true
      table.remove(arg, 1)
    elseif ("-c" == arg[1]) then
      config_path = arg[2]
      table.remove(arg, 1)
      table.remove(arg, 1)
    elseif (nil ~= arg[1]) then
      table.insert(files, arg[1])
      table.remove(arg, 1)
    else
    end
  end
  return files, config_path, show_checks_3f
end
local function show_checks(check_names, checks)
  for _, name in ipairs(check_names) do
    local metadata = checks[name]
    local pad1 = string.rep(" ", (20 - #name))
    local enabled_3f
    local function _2_()
      if metadata["enabled?"] then
        return "true"
      else
        return "false"
      end
    end
    local function _3_()
      if metadata["default?"] then
        return "true"
      else
        return "false"
      end
    end
    enabled_3f = (_2_() .. "(" .. _3_() .. ")")
    local pad2 = string.rep(" ", (13 - #enabled_3f))
    print((name .. pad1 .. enabled_3f .. pad2 .. (metadata.docstring or "")))
  end
  return nil
end
local function perform_ast_checks(check_names, checks, context, ast, root_3f)
  for _, name in ipairs(check_names) do
    local check = checks[name]
    if (check["enabled?"] and ("ast" == check.type) and check["apply?"](ast)) then
      check.fn(context, ast, root_3f)
    else
    end
  end
  if ("table" == type(ast)) then
    for _, v in pairs(ast) do
      if ("table" == type(v)) then
        perform_ast_checks(check_names, checks, context, v, false)
      else
      end
    end
    return nil
  else
    return nil
  end
end
local function perform_string_checks(context, checks)
  for number, line in ipairs(context["current-lines"]) do
    for _, check in pairs(checks) do
      if (check["enabled?"] and ("line" == check.type)) then
        check.fn(context, line, number)
      else
      end
    end
  end
  return nil
end
package.preload["utils"] = package.preload["utils"] or function(...)
  local fennel = require("fennel")
  local config = require("config").get()
  local color
  if (false ~= config.color) then
    color = {red = "\27[31m", yellow = "\27[33m", blue = "\27[34m", default = "\27[0m"}
  else
    color = {red = "", yellow = "", blue = "", default = ""}
  end
  local function unpack_2a(tbl)
    if table.unpack then
      return table.unpack(tbl)
    else
      return _G.unpack(tbl)
    end
  end
  local function _3f_3f_2e(t, k, ...)
    if (0 ~= #{...}) then
      if ("table" == type(t)) then
        return _3f_3f_2e(t[k], unpack_2a({...}))
      else
        return nil
      end
    else
      if ("table" == type(t)) then
        return t[k]
      else
        return nil
      end
    end
  end
  local function sym_3d(sym, name)
    return (fennel["sym?"](sym) and (name == _3f_3f_2e(sym, 1)))
  end
  local function print_table(tab, depth)
    local depth0
    if depth then
      depth0 = depth
    else
      depth0 = 0
    end
    print((string.rep("  ", depth0) .. "table: " .. tostring(tab)))
    for k, v in pairs(tab) do
      if ("table" ~= type(v)) then
        print((string.rep("  ", depth0) .. k .. " " .. tostring(v)))
      else
        print_table(v, (1 + depth0))
      end
    end
    return nil
  end
  local function position__3estring(node)
    if (nil ~= node.line) then
      return tostring(node.line)
    elseif (nil ~= getmetatable(node).line) then
      return tostring(getmetatable(node).line)
    else
      return "?"
    end
  end
  local function check_warning(context, linenumber, message)
    local _19_
    do
      local t_18_ = context
      if (nil ~= t_18_) then
        t_18_ = t_18_["skip-current-lines"]
      else
      end
      if (nil ~= t_18_) then
        t_18_ = t_18_[tostring(linenumber)]
      else
      end
      _19_ = t_18_
    end
    if not _19_ then
      if (context["return-value"] == 0) then
        context["return-value"] = 1
      else
      end
      local function _24_()
        local t_23_ = context
        if (nil ~= t_23_) then
          t_23_ = t_23_["current-lines"]
        else
        end
        if (nil ~= t_23_) then
          t_23_ = t_23_[tonumber(linenumber)]
        else
        end
        return t_23_
      end
      return print((color.yellow .. linenumber .. ": " .. message .. color.default .. "\n" .. _24_()))
    else
      return nil
    end
  end
  local function check_error(context, linenumber, message)
    local _29_
    do
      local t_28_ = context
      if (nil ~= t_28_) then
        t_28_ = t_28_["skip-current-lines"]
      else
      end
      if (nil ~= t_28_) then
        t_28_ = t_28_[tostring(linenumber)]
      else
      end
      _29_ = t_28_
    end
    if not _29_ then
      context["return-value"] = 2
      local function _33_()
        local t_32_ = context
        if (nil ~= t_32_) then
          t_32_ = t_32_["current-lines"]
        else
        end
        if (nil ~= t_32_) then
          t_32_ = t_32_[tonumber(linenumber)]
        else
        end
        return t_32_
      end
      return print((color.red .. linenumber .. ": " .. message .. color.default .. "\n" .. _33_()))
    else
      return nil
    end
  end
  return {color = color, ["??."] = _3f_3f_2e, ["sym="] = sym_3d, ["print-table"] = print_table, ["position->string"] = position__3estring, ["check-warning"] = check_warning, ["check-error"] = check_error}
end
package.preload["config"] = package.preload["config"] or function(...)
  local fennel = require("fennel")
  local config = {color = true, ["max-line-length"] = nil, checks = {}, ["anonymous-docstring"] = false}
  local function get_config()
    return config
  end
  local function load_config(file)
    _G.assert((nil ~= file), "Missing argument file on ./config.fnl:15")
    config = fennel.dofile(file)
    if (nil == config.checks) then
      config["checks"] = {}
      return nil
    else
      return nil
    end
  end
  return {get = get_config, load = load_config}
end
local function parse_directives(context, ast)
  local _let_8_ = require("utils")
  local position__3estring = _let_8_["position->string"]
  if fennel["comment?"](ast) then
    local linenumber = position__3estring(ast)
    if (("?" ~= linenumber) and string.match(tostring(ast), "no%-check")) then
      context["skip-current-lines"][tostring(tonumber(linenumber))] = true
      return nil
    else
      return nil
    end
  else
    if ("table" == type(ast)) then
      for _, v in pairs(ast) do
        if ("table" == type(v)) then
          parse_directives(context, v)
        else
        end
      end
      return nil
    else
      return nil
    end
  end
end
local function check_file(path, check_names, checks)
  local _let_41_ = require("utils")
  local color = _let_41_["color"]
  local context = {["current-lines"] = {}, ["current-file"] = "", ["skip-current-lines"] = {}, ["current-symbols"] = {}, ["return-value"] = 0}
  print((color.blue .. path .. color.default))
  do
    local f = io.open(path)
    local function close_handlers_10_auto(ok_11_auto, ...)
      f:close()
      if ok_11_auto then
        return ...
      else
        return error(..., 0)
      end
    end
    local function _43_()
      for line in f:lines() do
        table.insert(context["current-lines"], line)
      end
      f:seek("set", 0)
      do end (context)["current-file"] = f:read("*a")
      return nil
    end
    close_handlers_10_auto(_G.xpcall(_43_, (package.loaded.fennel or debug).traceback))
  end
  do
    local parse = fennel.parser(context["current-file"], nil, {comments = true})
    local function iterate()
      local pcall_ok, parse_ok, ast = pcall(parse)
      if (pcall_ok and parse_ok) then
        parse_directives(context, ast)
        return iterate()
      else
        return nil
      end
    end
    iterate()
  end
  perform_string_checks(context, checks)
  do
    local parse = fennel.parser(context["current-file"], nil, {comments = true})
    local function iterate()
      local pcall_ok, parse_ok, ast = pcall(parse)
      if (pcall_ok and parse_ok) then
        perform_ast_checks(check_names, checks, context, ast, true)
        return iterate()
      else
        return nil
      end
    end
    iterate()
  end
  return context["return-value"]
end
package.preload["list-checks"] = package.preload["list-checks"] or function(...)
  local fennel = require("fennel")
  local _local_47_ = require("utils")
  local _3f_3f_2e = _local_47_["??."]
  local position__3estring = _local_47_["position->string"]
  local check_warning = _local_47_["check-warning"]
  local check_error = _local_47_["check-error"]
  local sym_3d = _local_47_["sym="]
  local config = require("config").get()
  local list_checks = {}
  local function _48_(context, ast)
    local deprecated = {["require-macros"] = "0.4.0", ["pick-args"] = "0.10.0", global = "1.1.0"}
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1, 1)
    local since = deprecated[form]
    if (fennel["sym?"](ast[1]) and (nil ~= since)) then
      return check_warning(context, position, (form .. " is deprecated since " .. since))
    else
      return nil
    end
  end
  list_checks["deprecated"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for deprecated forms", ["enabled?"] = true, fn = _48_, type = "ast"}
  local function _50_(context, ast)
    local forms = {["for"] = true, each = true, icollect = true, collect = true, fcollect = true, accumulate = true, faccumulate = true}
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1, 1)
    if forms[form] then
      local bindings = _3f_3f_2e(ast, 2)
      if fennel["table?"](bindings) then
        local clauses
        do
          local tbl_19_auto = {}
          local i_20_auto = 0
          for _, v in pairs(bindings) do
            local val_21_auto
            if (("until" == v) or ("into" == v)) then
              val_21_auto = v
            else
              val_21_auto = nil
            end
            if (nil ~= val_21_auto) then
              i_20_auto = (i_20_auto + 1)
              do end (tbl_19_auto)[i_20_auto] = val_21_auto
            else
            end
          end
          clauses = tbl_19_auto
        end
        for _, v in ipairs(clauses) do
          if (v == "until") then
            check_warning(context, position, (":until is deprecated in " .. form .. ", use &until"))
          elseif (v == "into") then
            check_warning(context, position, (":into is deprecated in " .. form .. ", use &into"))
          else
          end
        end
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  list_checks["deprecated-clause"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for the use of :until/:into or instead of &until/&into", ["enabled?"] = true, fn = _50_, type = "ast"}
  local function _56_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    if (sym_3d(form, "if") and (#ast < 5)) then
      local _else = _3f_3f_2e(ast, 4)
      if (sym_3d(_else, "nil") or (nil == _else)) then
        return check_warning(context, position, "if the body causes side-effects, replace this if with when")
      else
        return nil
      end
    else
      return nil
    end
  end
  list_checks["if->when"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for if expressions that can be replaced with when", ["enabled?"] = true, fn = _56_, type = "ast"}
  local function _59_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    local has_docstring_3f
    local function _60_(ast0, pos)
      local function _62_()
        local t_61_ = ast0
        if (nil ~= t_61_) then
          t_61_ = t_61_[pos]
        else
        end
        return t_61_
      end
      local function _65_()
        local t_64_ = ast0
        if (nil ~= t_64_) then
          t_64_ = t_64_[pos]
        else
        end
        return t_64_
      end
      local _68_
      do
        local t_67_ = ast0
        if (nil ~= t_67_) then
          t_67_ = t_67_[pos]
        else
        end
        _68_ = t_67_
      end
      return (("string" == type(_62_())) or (("table" == type(_65_())) and ("string" == type(_3f_3f_2e(_68_, "fnl/docstring")))))
    end
    has_docstring_3f = _60_
    if (sym_3d(form, "fn") or sym_3d(form, "macro") or sym_3d(form, "lambda") or sym_3d(form, "\206\187")) then
      local function _71_()
        local t_70_ = ast
        if (nil ~= t_70_) then
          t_70_ = t_70_[2]
        else
        end
        return t_70_
      end
      if fennel["sequence?"](_71_()) then
        if (config["anonymous-docstring"] and ((#ast <= 3) or not has_docstring_3f(ast, 3))) then
          return check_warning(context, position, ("anonymous " .. form[1] .. " has no docstring"))
        else
          return nil
        end
      else
        if ((#ast <= 4) or not has_docstring_3f(ast, 4)) then
          local function _75_()
            local t_74_ = ast
            if (nil ~= t_74_) then
              t_74_ = t_74_[2]
            else
            end
            if (nil ~= t_74_) then
              t_74_ = t_74_[1]
            else
            end
            return t_74_
          end
          return check_warning(context, position, (form[1] .. " " .. tostring(_75_()) .. " has no docstring"))
        else
          return nil
        end
      end
    else
      return nil
    end
  end
  list_checks["docstring"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks if functions and macros have docstrings", ["enabled?"] = true, fn = _59_, type = "ast"}
  local function _81_(context, ast)
    local forms = {let = 2, fn = 2, lambda = 2, ["\206\187"] = 2, ["do"] = 2, when = 3}
    local form = _3f_3f_2e(ast, 1, 1)
    if forms[form] then
      for index, node in pairs(ast) do
        if fennel["list?"](node) then
          local form2 = node[1]
          local position = position__3estring(node)
          if (sym_3d(form2, "do") and (forms[form] <= index)) then
            check_warning(context, position, ("do is useless inside of " .. form))
          else
          end
        else
        end
      end
      return nil
    else
      return nil
    end
  end
  list_checks["useless-do"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for useless do forms", ["enabled?"] = true, fn = _81_, type = "ast"}
  local function _85_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    if sym_3d(form, "let") then
      local bindings = _3f_3f_2e(ast, 2)
      if (fennel["table?"](bindings) and (0 == #bindings)) then
        check_warning(context, position, "let has no bindings")
      else
      end
      if (fennel["table?"](bindings) and (0 ~= (#bindings % 2))) then
        return check_error(context, position, "let requires an even number of bindings")
      else
        return nil
      end
    else
      return nil
    end
  end
  list_checks["syntax-let"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for invalid let bindings", ["enabled?"] = true, fn = _85_, type = "ast"}
  local function _89_(context, ast)
    local forms = {let = true, ["for"] = true, each = true, icollect = true, collect = true, fcollect = true, accumulate = true, faccumulate = true}
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1, 1)
    if forms[form] then
      local bindings = _3f_3f_2e(ast, 2)
      if not fennel["sequence?"](bindings) then
        return check_error(context, position, (form .. " requires a binding table as the first argument"))
      else
        return nil
      end
    else
      return nil
    end
  end
  list_checks["syntax-no-bindings"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for missing binding tables", ["enabled?"] = true, fn = _89_, type = "ast"}
  local function _92_(context, ast)
    local forms = {let = true, ["for"] = true, icollect = 1, collect = 2, fcollect = 1, accumulate = 1, faccumulate = 1, when = true}
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1, 1)
    if (forms[form] and (#ast < 3)) then
      check_error(context, position, (form .. " requires a body"))
    else
    end
    if ((1 == forms[form]) and (3 < #ast)) then
      check_error(context, position, (form .. " requires exactly one body expression"))
    else
    end
    if ((2 == forms[form]) and (4 < #ast)) then
      return check_error(context, position, (form .. " requires exactly one or two body expressions"))
    else
      return nil
    end
  end
  list_checks["syntax-body"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for missing or wrong body expressions", ["enabled?"] = true, fn = _92_, type = "ast"}
  local function _96_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    if sym_3d(form, "if") then
      if (#ast < 3) then
        return check_error(context, position, "if requires a condition and a body")
      else
        return nil
      end
    else
      return nil
    end
  end
  list_checks["syntax-if"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for invalid uses of if", ["enabled?"] = true, fn = _96_, type = "ast"}
  local function _99_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    local bindings = _3f_3f_2e(ast, 2)
    if (sym_3d(form, "for") and fennel["sequence?"](bindings) and (#bindings < 3)) then
      return check_error(context, position, "for requires a binding table with a symbol, start and stop points")
    else
      return nil
    end
  end
  list_checks["syntax-for"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for syntax errors in the for binding table", ["enabled?"] = true, fn = _99_, type = "ast"}
  local function _101_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    local bindings = _3f_3f_2e(ast, 2)
    if (sym_3d(form, "for") and fennel["sequence?"](bindings)) then
      for _, i in pairs(bindings) do
        if (fennel["list?"](i) and (sym_3d(i[1], "pairs") or sym_3d(i[1], "ipairs"))) then
          check_warning(context, position, "use each instead of for for general iteration")
        else
        end
      end
      return nil
    else
      return nil
    end
  end
  list_checks["for->each"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for uses of for that should be replaced with each", ["enabled?"] = true, fn = _101_, type = "ast"}
  local function _104_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    if sym_3d(form, "not") then
      local form0 = _3f_3f_2e(ast, 2, 1)
      if sym_3d(form0, "not") then
        return check_warning(context, position, "(not (not ...)) is useless")
      elseif sym_3d(form0, "not=") then
        return check_warning(context, position, "replace (not (not= ...)) with (= ...)")
      elseif sym_3d(form0, "~=") then
        return check_warning(context, position, "replace (not (~= ...)) with (= ...)")
      elseif sym_3d(form0, "=") then
        return check_warning(context, position, "replace (not (= ...)) with (not= ...)")
      elseif sym_3d(form0, "<") then
        return check_warning(context, position, "replace (not (< ...)) with (>= ...)")
      elseif sym_3d(form0, "<=") then
        return check_warning(context, position, "replace (not (<= ...)) with (> ...)")
      elseif sym_3d(form0, ">") then
        return check_warning(context, position, "replace (not (> ...)) with (<= ...)")
      elseif sym_3d(form0, ">=") then
        return check_warning(context, position, "replace (not (>= ...)) with (< ...)")
      else
        return nil
      end
    else
      return nil
    end
  end
  list_checks["useless-not"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for uses of not that can be replaced", ["enabled?"] = true, fn = _104_, type = "ast"}
  local function _107_(context, ast)
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1)
    if (fennel["list?"](ast) and not fennel["sym?"](form)) then
      return check_warning(context, position, "this list doesn't begin with an identifier")
    else
      return nil
    end
  end
  list_checks["identifier"] = {["apply?"] = fennel["list?"], ["default?"] = false, docstring = "Checks for lists that don't begin with an identifier", ["enabled?"] = false, fn = _107_, type = "ast"}
  local function _109_(context, ast, root_3f)
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1)
    if (not root_3f and sym_3d(form, "local")) then
      return check_warning(context, position, "this local can be replaced with let")
    else
      return nil
    end
  end
  list_checks["local->let"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for locals that can be replaced with let", ["enabled?"] = true, fn = _109_, type = "ast"}
  local function _111_(context, ast)
    local forms = {["="] = true, ["~="] = true, ["not="] = true, ["<"] = true, ["<="] = true, [">"] = true, [">="] = true}
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1, 1)
    if (fennel["sym?"](ast[1]) and (nil ~= forms[form]) and (#ast < 3)) then
      return check_error(context, position, (form .. " requires at least two arguments"))
    else
      return nil
    end
  end
  list_checks["syntax-relational"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for relational operators that are missing an operand", ["enabled?"] = true, fn = _111_, type = "ast"}
  local function _113_(context, ast)
    local forms = {["+"] = true, ["%"] = true, ["*"] = true, ["."] = true, [".."] = true, ["//"] = true, ["?."] = true, ["^"] = true, ["or"] = true, ["and"] = true, ["math.min"] = true, ["math.max"] = true, ["do"] = true, doto = true, ["->"] = true, ["->>"] = true, ["-?>"] = true, ["-?>>"] = true}
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1, 1)
    if (fennel["sym?"](ast[1]) and (nil ~= forms[form]) and (#ast < 3)) then
      return check_warning(context, position, (form .. " is useless with a single argument"))
    else
      return nil
    end
  end
  list_checks["useless-forms"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for forms that are useless with one argument", ["enabled?"] = true, fn = _113_, type = "ast"}
  local function _115_(context, ast)
    local position = position__3estring(ast)
    local form = ast[1]
    if sym_3d(form, "#") then
      return check_warning(context, position, "# can be replaced with length")
    elseif sym_3d(form, "~=") then
      return check_warning(context, position, "~= can be replaced with not=")
    else
      return nil
    end
  end
  list_checks["style-alternatives"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for forms that have multiple names", ["enabled?"] = true, fn = _115_, type = "ast"}
  local function _117_(context, ast, root_3f)
    if root_3f then
      local function check_symbol(symbol, position, form)
        if (symbol and context["current-symbols"][symbol]) then
          return check_warning(context, position, ("this " .. form .. " redefines " .. context["current-symbols"][symbol].form .. " " .. symbol .. " (line " .. context["current-symbols"][symbol].position .. ")"))
        elseif symbol then
          context["current-symbols"][symbol] = {position = position, form = form}
          return nil
        else
          return nil
        end
      end
      local form = ast[1]
      local position = position__3estring(ast)
      if (sym_3d(form, "global") or sym_3d(form, "local") or sym_3d(form, "var") or sym_3d(form, "macro")) then
        return check_symbol(ast[2][1], position, form[1])
      elseif ((sym_3d(form, "fn") or sym_3d(form, "\206\187") or sym_3d(form, "lambda")) and fennel["sym?"](ast[2])) then
        return check_symbol(ast[2][1], position, form[1])
      elseif sym_3d(form, "macros") then
        for k in pairs(ast[2]) do
          check_symbol(k, position, form[1])
        end
        return nil
      else
        return nil
      end
    else
      return nil
    end
  end
  list_checks["redefine"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for redefined symbols", ["enabled?"] = true, fn = _117_, type = "ast"}
  local function _121_(context, ast, root_3f)
    local function check_symbol(symbol, position, form, root_3f0)
      if (symbol and context["current-symbols"][symbol] and not root_3f0) then
        return check_warning(context, position, ("this " .. form .. " shadows " .. context["current-symbols"][symbol].form .. " " .. symbol .. " (line " .. context["current-symbols"][symbol].position .. ")"))
      else
        return nil
      end
    end
    local form = ast[1]
    local position = position__3estring(ast)
    if (sym_3d(form, "global") or sym_3d(form, "local") or sym_3d(form, "var") or sym_3d(form, "macro")) then
      return check_symbol(ast[2][1], position, form[1], root_3f)
    elseif ((sym_3d(form, "fn") or sym_3d(form, "\206\187") or sym_3d(form, "lambda")) and fennel["sym?"](ast[2])) then
      return check_symbol(ast[2][1], position, form[1], root_3f)
    elseif (("table" == type(ast[2])) and sym_3d(form, "macros")) then
      for k in pairs(ast[2]) do
        check_symbol(k, position, form[1], root_3f)
      end
      return nil
    elseif (("table" == type(ast[2])) and sym_3d(form, "let")) then
      for k, v in ipairs(ast[2]) do
        if (1 == (k % 2)) then
          check_symbol(v[1], position, form[1], false)
        else
        end
      end
      return nil
    else
      return nil
    end
  end
  list_checks["shadow"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for shadowed symbols", ["enabled?"] = true, fn = _121_, type = "ast"}
  local function _125_(context, ast)
    local forms = {[">"] = true, [">="] = true, hashfn = true, ["eval-compiler"] = true, lua = true}
    local position = position__3estring(ast)
    local form = _3f_3f_2e(ast, 1, 1)
    if forms[form] then
      return check_warning(context, position, ("avoid using " .. form))
    else
      return nil
    end
  end
  list_checks["style-bad-forms"] = {["apply?"] = fennel["list?"], ["default?"] = true, docstring = "Checks for forms that should be avoided", ["enabled?"] = true, fn = _125_, type = "ast"}
  local function _127_(context, ast)
    local position = position__3estring(ast)
    local function _128_(...)
      local function _133_(...)
        if fennel["sym?"](ast[1]) then
          local _130_
          do
            local t_129_ = ast
            if (nil ~= t_129_) then
              t_129_ = t_129_[1]
            else
            end
            if (nil ~= t_129_) then
              t_129_ = t_129_[1]
            else
            end
            _130_ = t_129_
          end
          return (_130_ == "=")
        else
          return false
        end
      end
      local function _138_(...)
        if fennel["sym?"](ast[2]) then
          local _135_
          do
            local t_134_ = ast
            if (nil ~= t_134_) then
              t_134_ = t_134_[2]
            else
            end
            if (nil ~= t_134_) then
              t_134_ = t_134_[1]
            else
            end
            _135_ = t_134_
          end
          return (_135_ == "nil")
        else
          return false
        end
      end
      return ((#ast == 3) and _133_(...) and _138_(...) and true)
    end
    local function _139_(...)
      local function _144_(...)
        if fennel["sym?"](ast[1]) then
          local _141_
          do
            local t_140_ = ast
            if (nil ~= t_140_) then
              t_140_ = t_140_[1]
            else
            end
            if (nil ~= t_140_) then
              t_140_ = t_140_[1]
            else
            end
            _141_ = t_140_
          end
          return (_141_ == "=")
        else
          return false
        end
      end
      local function _149_(...)
        if fennel["sym?"](ast[3]) then
          local _146_
          do
            local t_145_ = ast
            if (nil ~= t_145_) then
              t_145_ = t_145_[3]
            else
            end
            if (nil ~= t_145_) then
              t_145_ = t_145_[1]
            else
            end
            _146_ = t_145_
          end
          return (_146_ == "nil")
        else
          return false
        end
      end
      return ((#ast == 3) and _144_(...) and true and _149_(...))
    end
    if (_128_() or _139_()) then
      return check_warning(context, position, "use cljlib.nil? instead of (= nil ...)")
    else
      local function _150_(...)
        local function _155_(...)
          if fennel["sym?"](ast[1]) then
            local _152_
            do
              local t_151_ = ast
              if (nil ~= t_151_) then
                t_151_ = t_151_[1]
              else
              end
              if (nil ~= t_151_) then
                t_151_ = t_151_[1]
              else
              end
              _152_ = t_151_
            end
            return (_152_ == "=")
          else
            return false
          end
        end
        return ((#ast == 3) and _155_(...) and (ast[2] == 0) and true)
      end
      local function _156_(...)
        local function _161_(...)
          if fennel["sym?"](ast[1]) then
            local _158_
            do
              local t_157_ = ast
              if (nil ~= t_157_) then
                t_157_ = t_157_[1]
              else
              end
              if (nil ~= t_157_) then
                t_157_ = t_157_[1]
              else
              end
              _158_ = t_157_
            end
            return (_158_ == "=")
          else
            return false
          end
        end
        return ((#ast == 3) and _161_(...) and true and (ast[3] == 0))
      end
      if (_150_() or _156_()) then
        return check_warning(context, position, "use cljlib.zero? instead of (= 0 ...)")
      else
        local function _166_()
          if fennel["sym?"](ast[1]) then
            local _163_
            do
              local t_162_ = ast
              if (nil ~= t_162_) then
                t_162_ = t_162_[1]
              else
              end
              if (nil ~= t_162_) then
                t_162_ = t_162_[1]
              else
              end
              _163_ = t_162_
            end
            return (_163_ == ">")
          else
            return false
          end
        end
        if ((#ast == 3) and _166_() and true and (ast[3] == 0)) then
          return check_warning(context, position, "use cljlib.pos? instead of (> ... 0)")
        else
          local function _171_()
            if fennel["sym?"](ast[1]) then
              local _168_
              do
                local t_167_ = ast
                if (nil ~= t_167_) then
                  t_167_ = t_167_[1]
                else
                end
                if (nil ~= t_167_) then
                  t_167_ = t_167_[1]
                else
                end
                _168_ = t_167_
              end
              return (_168_ == "<")
            else
              return false
            end
          end
          if ((#ast == 3) and _171_() and (ast[2] == 0) and true) then
            return check_warning(context, position, "use cljlib.pos? instead of (< 0 ...)")
          else
            local function _176_()
              if fennel["sym?"](ast[1]) then
                local _173_
                do
                  local t_172_ = ast
                  if (nil ~= t_172_) then
                    t_172_ = t_172_[1]
                  else
                  end
                  if (nil ~= t_172_) then
                    t_172_ = t_172_[1]
                  else
                  end
                  _173_ = t_172_
                end
                return (_173_ == "<")
              else
                return false
              end
            end
            if ((#ast == 3) and _176_() and true and (ast[3] == 0)) then
              return check_warning(context, position, "use cljlib.neg? instead of (< ... 0)")
            else
              local function _181_()
                if fennel["sym?"](ast[1]) then
                  local _178_
                  do
                    local t_177_ = ast
                    if (nil ~= t_177_) then
                      t_177_ = t_177_[1]
                    else
                    end
                    if (nil ~= t_177_) then
                      t_177_ = t_177_[1]
                    else
                    end
                    _178_ = t_177_
                  end
                  return (_178_ == ">")
                else
                  return false
                end
              end
              if ((#ast == 3) and _181_() and (ast[2] == 0) and true) then
                return check_warning(context, position, "use cljlib.neg? instead of (> 0 ...)")
              else
                local function _182_(...)
                  local function _187_(...)
                    if fennel["sym?"](ast[1]) then
                      local _184_
                      do
                        local t_183_ = ast
                        if (nil ~= t_183_) then
                          t_183_ = t_183_[1]
                        else
                        end
                        if (nil ~= t_183_) then
                          t_183_ = t_183_[1]
                        else
                        end
                        _184_ = t_183_
                      end
                      return (_184_ == "=")
                    else
                      return false
                    end
                  end
                  local function _193_(...)
                    if fennel["list?"](ast[2]) then
                      local function _192_(...)
                        if fennel["sym?"](ast[2][1]) then
                          local _189_
                          do
                            local t_188_ = ast[2]
                            if (nil ~= t_188_) then
                              t_188_ = t_188_[1]
                            else
                            end
                            if (nil ~= t_188_) then
                              t_188_ = t_188_[1]
                            else
                            end
                            _189_ = t_188_
                          end
                          return (_189_ == "%")
                        else
                          return false
                        end
                      end
                      return ((#ast[2] == 3) and _192_(...) and true and (ast[2][3] == 2))
                    else
                      return false
                    end
                  end
                  return ((#ast == 3) and _187_(...) and _193_(...) and (ast[3] == 0))
                end
                local function _194_(...)
                  local function _199_(...)
                    if fennel["sym?"](ast[1]) then
                      local _196_
                      do
                        local t_195_ = ast
                        if (nil ~= t_195_) then
                          t_195_ = t_195_[1]
                        else
                        end
                        if (nil ~= t_195_) then
                          t_195_ = t_195_[1]
                        else
                        end
                        _196_ = t_195_
                      end
                      return (_196_ == "=")
                    else
                      return false
                    end
                  end
                  local function _205_(...)
                    if fennel["list?"](ast[3]) then
                      local function _204_(...)
                        if fennel["sym?"](ast[3][1]) then
                          local _201_
                          do
                            local t_200_ = ast[3]
                            if (nil ~= t_200_) then
                              t_200_ = t_200_[1]
                            else
                            end
                            if (nil ~= t_200_) then
                              t_200_ = t_200_[1]
                            else
                            end
                            _201_ = t_200_
                          end
                          return (_201_ == "%")
                        else
                          return false
                        end
                      end
                      return ((#ast[3] == 3) and _204_(...) and true and (ast[3][3] == 2))
                    else
                      return false
                    end
                  end
                  return ((#ast == 3) and _199_(...) and (ast[2] == 0) and _205_(...))
                end
                if (_182_() or _194_()) then
                  return check_warning(context, position, "use cljlib.even? instead of (= 0 (% ... 2))")
                else
                  local function _206_(...)
                    local function _211_(...)
                      if fennel["sym?"](ast[1]) then
                        local _208_
                        do
                          local t_207_ = ast
                          if (nil ~= t_207_) then
                            t_207_ = t_207_[1]
                          else
                          end
                          if (nil ~= t_207_) then
                            t_207_ = t_207_[1]
                          else
                          end
                          _208_ = t_207_
                        end
                        return (_208_ == "not=")
                      else
                        return false
                      end
                    end
                    local function _217_(...)
                      if fennel["list?"](ast[2]) then
                        local function _216_(...)
                          if fennel["sym?"](ast[2][1]) then
                            local _213_
                            do
                              local t_212_ = ast[2]
                              if (nil ~= t_212_) then
                                t_212_ = t_212_[1]
                              else
                              end
                              if (nil ~= t_212_) then
                                t_212_ = t_212_[1]
                              else
                              end
                              _213_ = t_212_
                            end
                            return (_213_ == "%")
                          else
                            return false
                          end
                        end
                        return ((#ast[2] == 3) and _216_(...) and true and (ast[2][3] == 2))
                      else
                        return false
                      end
                    end
                    return ((#ast == 3) and _211_(...) and _217_(...) and (ast[3] == 0))
                  end
                  local function _218_(...)
                    local function _223_(...)
                      if fennel["sym?"](ast[1]) then
                        local _220_
                        do
                          local t_219_ = ast
                          if (nil ~= t_219_) then
                            t_219_ = t_219_[1]
                          else
                          end
                          if (nil ~= t_219_) then
                            t_219_ = t_219_[1]
                          else
                          end
                          _220_ = t_219_
                        end
                        return (_220_ == "not=")
                      else
                        return false
                      end
                    end
                    local function _229_(...)
                      if fennel["list?"](ast[3]) then
                        local function _228_(...)
                          if fennel["sym?"](ast[3][1]) then
                            local _225_
                            do
                              local t_224_ = ast[3]
                              if (nil ~= t_224_) then
                                t_224_ = t_224_[1]
                              else
                              end
                              if (nil ~= t_224_) then
                                t_224_ = t_224_[1]
                              else
                              end
                              _225_ = t_224_
                            end
                            return (_225_ == "%")
                          else
                            return false
                          end
                        end
                        return ((#ast[3] == 3) and _228_(...) and true and (ast[3][3] == 2))
                      else
                        return false
                      end
                    end
                    return ((#ast == 3) and _223_(...) and (ast[2] == 0) and _229_(...))
                  end
                  if (_206_() or _218_()) then
                    return check_warning(context, position, "use cljlib.odd? instead of (not= 0 (% ... 2))")
                  else
                    local function _230_(...)
                      local function _235_(...)
                        if fennel["sym?"](ast[1]) then
                          local _232_
                          do
                            local t_231_ = ast
                            if (nil ~= t_231_) then
                              t_231_ = t_231_[1]
                            else
                            end
                            if (nil ~= t_231_) then
                              t_231_ = t_231_[1]
                            else
                            end
                            _232_ = t_231_
                          end
                          return (_232_ == "=")
                        else
                          return false
                        end
                      end
                      local function _241_(...)
                        if fennel["list?"](ast[2]) then
                          local function _240_(...)
                            if fennel["sym?"](ast[2][1]) then
                              local _237_
                              do
                                local t_236_ = ast[2]
                                if (nil ~= t_236_) then
                                  t_236_ = t_236_[1]
                                else
                                end
                                if (nil ~= t_236_) then
                                  t_236_ = t_236_[1]
                                else
                                end
                                _237_ = t_236_
                              end
                              return (_237_ == "%")
                            else
                              return false
                            end
                          end
                          return ((#ast[2] == 3) and _240_(...) and true and (ast[2][3] == 2))
                        else
                          return false
                        end
                      end
                      return ((#ast == 3) and _235_(...) and _241_(...) and (ast[3] == 1))
                    end
                    local function _242_(...)
                      local function _247_(...)
                        if fennel["sym?"](ast[1]) then
                          local _244_
                          do
                            local t_243_ = ast
                            if (nil ~= t_243_) then
                              t_243_ = t_243_[1]
                            else
                            end
                            if (nil ~= t_243_) then
                              t_243_ = t_243_[1]
                            else
                            end
                            _244_ = t_243_
                          end
                          return (_244_ == "=")
                        else
                          return false
                        end
                      end
                      local function _253_(...)
                        if fennel["list?"](ast[3]) then
                          local function _252_(...)
                            if fennel["sym?"](ast[3][1]) then
                              local _249_
                              do
                                local t_248_ = ast[3]
                                if (nil ~= t_248_) then
                                  t_248_ = t_248_[1]
                                else
                                end
                                if (nil ~= t_248_) then
                                  t_248_ = t_248_[1]
                                else
                                end
                                _249_ = t_248_
                              end
                              return (_249_ == "%")
                            else
                              return false
                            end
                          end
                          return ((#ast[3] == 3) and _252_(...) and true and (ast[3][3] == 2))
                        else
                          return false
                        end
                      end
                      return ((#ast == 3) and _247_(...) and (ast[2] == 1) and _253_(...))
                    end
                    if (_230_() or _242_()) then
                      return check_warning(context, position, "use cljlib.odd? instead of (= 1 (% ... 2))")
                    else
                      local function _254_(...)
                        local function _259_(...)
                          if fennel["sym?"](ast[1]) then
                            local _256_
                            do
                              local t_255_ = ast
                              if (nil ~= t_255_) then
                                t_255_ = t_255_[1]
                              else
                              end
                              if (nil ~= t_255_) then
                                t_255_ = t_255_[1]
                              else
                              end
                              _256_ = t_255_
                            end
                            return (_256_ == "=")
                          else
                            return false
                          end
                        end
                        local function _265_(...)
                          if fennel["list?"](ast[2]) then
                            local function _264_(...)
                              if fennel["sym?"](ast[2][1]) then
                                local _261_
                                do
                                  local t_260_ = ast[2]
                                  if (nil ~= t_260_) then
                                    t_260_ = t_260_[1]
                                  else
                                  end
                                  if (nil ~= t_260_) then
                                    t_260_ = t_260_[1]
                                  else
                                  end
                                  _261_ = t_260_
                                end
                                return (_261_ == "type")
                              else
                                return false
                              end
                            end
                            return ((#ast[2] == 2) and _264_(...) and true)
                          else
                            return false
                          end
                        end
                        return ((#ast == 3) and _259_(...) and _265_(...) and (ast[3] == "string"))
                      end
                      local function _266_(...)
                        local function _271_(...)
                          if fennel["sym?"](ast[1]) then
                            local _268_
                            do
                              local t_267_ = ast
                              if (nil ~= t_267_) then
                                t_267_ = t_267_[1]
                              else
                              end
                              if (nil ~= t_267_) then
                                t_267_ = t_267_[1]
                              else
                              end
                              _268_ = t_267_
                            end
                            return (_268_ == "=")
                          else
                            return false
                          end
                        end
                        local function _277_(...)
                          if fennel["list?"](ast[3]) then
                            local function _276_(...)
                              if fennel["sym?"](ast[3][1]) then
                                local _273_
                                do
                                  local t_272_ = ast[3]
                                  if (nil ~= t_272_) then
                                    t_272_ = t_272_[1]
                                  else
                                  end
                                  if (nil ~= t_272_) then
                                    t_272_ = t_272_[1]
                                  else
                                  end
                                  _273_ = t_272_
                                end
                                return (_273_ == "type")
                              else
                                return false
                              end
                            end
                            return ((#ast[3] == 2) and _276_(...) and true)
                          else
                            return false
                          end
                        end
                        return ((#ast == 3) and _271_(...) and (ast[2] == "string") and _277_(...))
                      end
                      if (_254_() or _266_()) then
                        return check_warning(context, position, "use cljlib.string? instead of (= :string (type ...))")
                      else
                        local function _278_(...)
                          local function _283_(...)
                            if fennel["sym?"](ast[1]) then
                              local _280_
                              do
                                local t_279_ = ast
                                if (nil ~= t_279_) then
                                  t_279_ = t_279_[1]
                                else
                                end
                                if (nil ~= t_279_) then
                                  t_279_ = t_279_[1]
                                else
                                end
                                _280_ = t_279_
                              end
                              return (_280_ == "=")
                            else
                              return false
                            end
                          end
                          local function _289_(...)
                            if fennel["list?"](ast[2]) then
                              local function _288_(...)
                                if fennel["sym?"](ast[2][1]) then
                                  local _285_
                                  do
                                    local t_284_ = ast[2]
                                    if (nil ~= t_284_) then
                                      t_284_ = t_284_[1]
                                    else
                                    end
                                    if (nil ~= t_284_) then
                                      t_284_ = t_284_[1]
                                    else
                                    end
                                    _285_ = t_284_
                                  end
                                  return (_285_ == "type")
                                else
                                  return false
                                end
                              end
                              return ((#ast[2] == 2) and _288_(...) and true)
                            else
                              return false
                            end
                          end
                          return ((#ast == 3) and _283_(...) and _289_(...) and (ast[3] == "boolean"))
                        end
                        local function _290_(...)
                          local function _295_(...)
                            if fennel["sym?"](ast[1]) then
                              local _292_
                              do
                                local t_291_ = ast
                                if (nil ~= t_291_) then
                                  t_291_ = t_291_[1]
                                else
                                end
                                if (nil ~= t_291_) then
                                  t_291_ = t_291_[1]
                                else
                                end
                                _292_ = t_291_
                              end
                              return (_292_ == "=")
                            else
                              return false
                            end
                          end
                          local function _301_(...)
                            if fennel["list?"](ast[3]) then
                              local function _300_(...)
                                if fennel["sym?"](ast[3][1]) then
                                  local _297_
                                  do
                                    local t_296_ = ast[3]
                                    if (nil ~= t_296_) then
                                      t_296_ = t_296_[1]
                                    else
                                    end
                                    if (nil ~= t_296_) then
                                      t_296_ = t_296_[1]
                                    else
                                    end
                                    _297_ = t_296_
                                  end
                                  return (_297_ == "type")
                                else
                                  return false
                                end
                              end
                              return ((#ast[3] == 2) and _300_(...) and true)
                            else
                              return false
                            end
                          end
                          return ((#ast == 3) and _295_(...) and (ast[2] == "boolean") and _301_(...))
                        end
                        if (_278_() or _290_()) then
                          return check_warning(context, position, "use cljlib.boolean? instead of (= :boolean (type ...))")
                        else
                          local function _302_(...)
                            local function _307_(...)
                              if fennel["sym?"](ast[1]) then
                                local _304_
                                do
                                  local t_303_ = ast
                                  if (nil ~= t_303_) then
                                    t_303_ = t_303_[1]
                                  else
                                  end
                                  if (nil ~= t_303_) then
                                    t_303_ = t_303_[1]
                                  else
                                  end
                                  _304_ = t_303_
                                end
                                return (_304_ == "=")
                              else
                                return false
                              end
                            end
                            return ((#ast == 3) and _307_(...) and (ast[2] == true) and true)
                          end
                          local function _308_(...)
                            local function _313_(...)
                              if fennel["sym?"](ast[1]) then
                                local _310_
                                do
                                  local t_309_ = ast
                                  if (nil ~= t_309_) then
                                    t_309_ = t_309_[1]
                                  else
                                  end
                                  if (nil ~= t_309_) then
                                    t_309_ = t_309_[1]
                                  else
                                  end
                                  _310_ = t_309_
                                end
                                return (_310_ == "=")
                              else
                                return false
                              end
                            end
                            return ((#ast == 3) and _313_(...) and true and (ast[3] == true))
                          end
                          if (_302_() or _308_()) then
                            return check_warning(context, position, "use cljlib.true? instead of (= true ...)")
                          else
                            local function _314_(...)
                              local function _319_(...)
                                if fennel["sym?"](ast[1]) then
                                  local _316_
                                  do
                                    local t_315_ = ast
                                    if (nil ~= t_315_) then
                                      t_315_ = t_315_[1]
                                    else
                                    end
                                    if (nil ~= t_315_) then
                                      t_315_ = t_315_[1]
                                    else
                                    end
                                    _316_ = t_315_
                                  end
                                  return (_316_ == "=")
                                else
                                  return false
                                end
                              end
                              return ((#ast == 3) and _319_(...) and (ast[2] == false) and true)
                            end
                            local function _320_(...)
                              local function _325_(...)
                                if fennel["sym?"](ast[1]) then
                                  local _322_
                                  do
                                    local t_321_ = ast
                                    if (nil ~= t_321_) then
                                      t_321_ = t_321_[1]
                                    else
                                    end
                                    if (nil ~= t_321_) then
                                      t_321_ = t_321_[1]
                                    else
                                    end
                                    _322_ = t_321_
                                  end
                                  return (_322_ == "=")
                                else
                                  return false
                                end
                              end
                              return ((#ast == 3) and _325_(...) and true and (ast[3] == false))
                            end
                            if (_314_() or _320_()) then
                              return check_warning(context, position, "use cljlib.false? instead of (= false ...)")
                            else
                              return nil
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  list_checks["cljlib/predicates"] = {["apply?"] = fennel["list?"], ["default?"] = false, docstring = "Checks for comparisons that can be repleced with cljlib predicates", ["enabled?"] = false, fn = _127_, type = "ast"}
  return list_checks
end
package.preload["sym-checks"] = package.preload["sym-checks"] or function(...)
  local fennel = require("fennel")
  local _local_327_ = require("utils")
  local position__3estring = _local_327_["position->string"]
  local check_warning = _local_327_["check-warning"]
  local sym_checks = {}
  local function _328_(context, ast)
    local position = position__3estring(ast)
    local name
    do
      local t_329_ = ast
      if (nil ~= t_329_) then
        t_329_ = t_329_[1]
      else
      end
      name = t_329_
    end
    if (("string" == type(name)) and string.match(string.sub(name, 2), "[A-Z_]+")) then
      return check_warning(context, position, "don't use [A-Z_] in names")
    else
      return nil
    end
  end
  sym_checks["symbols"] = {["apply?"] = fennel["sym?"], ["default?"] = true, docstring = "Checks names for bad symbols", ["enabled?"] = true, fn = _328_, type = "ast"}
  return sym_checks
end
package.preload["table-checks"] = package.preload["table-checks"] or function(...)
  local fennel = require("fennel")
  local _local_332_ = require("utils")
  local position__3estring = _local_332_["position->string"]
  local check_warning = _local_332_["check-warning"]
  local function kv_table_3f(ast)
    return (("table" == type(ast)) and not fennel["list?"](ast) and not fennel["sym?"](ast) and not fennel["varg?"](ast) and not fennel["comment?"](ast) and not fennel["sequence?"](ast))
  end
  local table_checks = {}
  local function _333_(context, ast)
    local position = position__3estring(ast)
    local keys = {}
    for _, k in ipairs(getmetatable(ast).keys) do
      if keys[k] then
        check_warning(context, position, ("key " .. tostring(k) .. " occurs multiple times"))
      else
      end
      keys[k] = true
    end
    return nil
  end
  table_checks["duplicate-keys"] = {["apply?"] = kv_table_3f, ["default?"] = true, docstring = "Checks for duplicate keys in tables", ["enabled?"] = true, fn = _333_, type = "ast"}
  local function _335_(context, ast)
    local position = position__3estring(ast)
    local keys = {}
    for _, k in ipairs(getmetatable(ast).keys) do
      keys[k] = true
    end
    if (0 < #ast) then
      local function iterate(i, sequence_3f)
        if (i <= #getmetatable(ast).keys) then
          return iterate((1 + i), (sequence_3f and keys[i]))
        elseif (sequence_3f and (#getmetatable(ast).keys < i)) then
          return check_warning(context, position, "this table can be written as a sequence")
        else
          return nil
        end
      end
      return iterate(1, true)
    else
      return nil
    end
  end
  table_checks["table->sequence"] = {["apply?"] = kv_table_3f, ["default?"] = true, docstring = "Checks for tables that can be written as sequences", ["enabled?"] = true, fn = _335_, type = "ast"}
  return table_checks
end
package.preload["comment-checks"] = package.preload["comment-checks"] or function(...)
  local fennel = require("fennel")
  local _local_338_ = require("utils")
  local position__3estring = _local_338_["position->string"]
  local check_warning = _local_338_["check-warning"]
  local comment_checks = {}
  local function _339_(context, ast)
    local linenumber = position__3estring(ast)
    if ("?" ~= linenumber) then
      local linenumber0 = tonumber(linenumber)
      local line
      do
        local t_340_ = context
        if (nil ~= t_340_) then
          t_340_ = t_340_["current-lines"]
        else
        end
        if (nil ~= t_340_) then
          t_340_ = t_340_[linenumber0]
        else
        end
        line = t_340_
      end
      local comment_string = tostring(ast)
      local code_string = string.sub(line, 1, (#line - #comment_string))
      if (string.match(code_string, "^[ \9]*$") and string.match(comment_string, "^;[^;]*$")) then
        check_warning(context, linenumber0, "this comment should start with at least two semicolons")
      else
      end
      if (string.match(code_string, "[^ \9;]+[ \9]*$") and string.match(comment_string, "^;;")) then
        return check_warning(context, linenumber0, "this comment should start with one semicolon")
      else
        return nil
      end
    else
      return nil
    end
  end
  comment_checks["style-comments"] = {["apply?"] = fennel["comment?"], ["default?"] = true, docstring = "Checks if comments start with the correct number of semicolons", ["enabled?"] = true, fn = _339_, type = "ast"}
  return comment_checks
end
package.preload["string-checks"] = package.preload["string-checks"] or function(...)
  local _local_346_ = require("utils")
  local check_warning = _local_346_["check-warning"]
  local config = require("config").get()
  local function len(str)
    local _348_
    do
      local t_347_ = _G
      if (nil ~= t_347_) then
        t_347_ = t_347_.utf8
      else
      end
      if (nil ~= t_347_) then
        t_347_ = t_347_.len
      else
      end
      _348_ = t_347_
    end
    if _348_ then
      return _G.utf8.len(str)
    else
      return #str
    end
  end
  local string_checks = {}
  local function _352_()
    return true
  end
  local function _353_(context, line, number)
    local max_line_length = (config["max-line-length"] or 80)
    if (max_line_length < len(line)) then
      return check_warning(context, number, ("line length exceeds " .. max_line_length .. " columns"))
    else
      return nil
    end
  end
  string_checks["style-length"] = {["apply?"] = _352_, ["default?"] = true, docstring = "Checks if the line is to long", ["enabled?"] = true, fn = _353_, type = "line"}
  local function _355_()
    return true
  end
  local function _356_(context, line, number)
    if string.match(line, "^[ \9]*[])}]+[ \9]*$") then
      return check_warning(context, number, "closing delimiters should not appear on their own line")
    else
      return nil
    end
  end
  string_checks["style-delimiters"] = {["apply?"] = _355_, ["default?"] = true, docstring = "Checks if closing delimiters appear on their own line", ["enabled?"] = true, fn = _356_, type = "line"}
  return string_checks
end
local function main()
  local files, config_path, show_checks_3f = parse_arg()
  local checks = {}
  local check_names = {}
  if config_path then
    require("config").load(config_path)
  else
  end
  local return_value = 0
  for k_2_auto, v_3_auto in pairs(require("list-checks")) do
    checks[k_2_auto] = v_3_auto
  end
  for k_2_auto, v_3_auto in pairs(require("sym-checks")) do
    checks[k_2_auto] = v_3_auto
  end
  for k_2_auto, v_3_auto in pairs(require("table-checks")) do
    checks[k_2_auto] = v_3_auto
  end
  for k_2_auto, v_3_auto in pairs(require("comment-checks")) do
    checks[k_2_auto] = v_3_auto
  end
  for k_2_auto, v_3_auto in pairs(require("string-checks")) do
    checks[k_2_auto] = v_3_auto
  end
  do
    local config = require("config").get()
    if ("table" == type(config.checks)) then
      for check in pairs(config.checks) do
        if ("table" == type(checks[check])) then
          if config.checks[check] then
            checks[check]["enabled?"] = true
          else
            checks[check]["enabled?"] = false
          end
        else
        end
      end
    else
    end
  end
  for name in pairs(checks) do
    table.insert(check_names, name)
  end
  table.sort(check_names)
  if show_checks_3f then
    show_checks(check_names, checks)
    os.exit(0)
  else
  end
  for _, file in ipairs(files) do
    return_value = math.max(return_value, check_file(file, check_names, checks))
    print()
  end
  return os.exit(return_value)
end
return main()
