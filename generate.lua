#!/usr/bin/lua5.3

-- Define version number
version = 
   {  major = 1
   ,  minor = 0
   ,  patch = 0
   }

function vers()
   return version.major .. "." .. version.minor .. "." .. version.patch
end

-- Define compiler table
compilers = 
   -- Clang compiler
   {  {  name = "Clang"
      ,  prep = 
            {  "__clang__"
            }
      ,  prag =
            {  push = "#pragma clang diagnostic push"
            ,  pop  = "#pragma clang diagnostic pop"
            ,  warn = "#pragma clang diagnostic ignored"
            }
      }
   -- Intel compiler
   ,  {  name = "Intel"
      ,  prep = 
            {  "__INTEL_COMPILER"
            }
      ,  prag =
            {  push = "#pragma warning push"
            ,  pop  = "#pragma warning pop"   
            ,  warn = "#pragma warning(disable : %__WARNING_NUMBER__)"
            }
      }
   -- GCC compiler
   ,  {  name = "GCC"  
      ,  prep = 
            {  "__GNUC__"
            } 
      ,  prag =
            {  push = "#pragma GCC diagnostic push"
            ,  pop  = "#pragma GCC diagnostic pop"
            ,  warn = "#pragma GCC diagnostic ignored"
            }
      }
   }

-- Define warning table. Format : {clang/gcc, intel, MSVC}
warnings = 
   {  "c++98-compat"
   ,  "c++98-compat-pedantic"
   ,  "assign-base-inaccessible"
   ,  "assign-could-not-be-generated"
   ,  "copy-ctor-could-not-be-generated"
   ,  "dflt-ctor-base-inaccessible"
   ,  "dflt-ctor-could-not-be-generated"
   ,  "user-ctor-required"
   ,  "automatic-inline"
   ,  "force-not-inlined"
   ,  "not-inlined"
   ,  "unreferenced-inline"
   ,  "behavior-change"
   ,  "bool-conversion"
   ,  "c++11-extensions"
   ,  "cast-align"
   ,  "catch-semantic-changed"
   ,  "conditional-uninitialized"
   ,  "constant-conditional"
   ,  "constant-conversion"
   ,  "conversion"
   ,  "conversion-loss"
   ,  "conversion-sign-extended"
   ,  "covered-switch-default"
   ,  "deprecated"
   ,  "deprecated-declarations"
   ,  "deprecated-objc-isa-usage"
   ,  "deprecated-register"
   ,  "digraphs-not-supported"
   ,  "disabled-macro-expansion"
   ,  "documentation"
   ,  "documentation-unknown-command"
   ,  "empty-body"
   ,  "enum-conversion"
   ,  "exit-time-destructors"
   ,  "extra-semi"
   ,  "format"
   ,  "four-char-constants"
   ,  "global-constructors"
   ,  "ill-formed-comma-expr"
   ,  "implicit-fallthrough"
   ,  "inherits-via-dominance"
   ,  "int-conversion"
   ,  "invalid-offsetof"
   ,  "is-defined-to-be"
   ,  "layout-changed"
   ,  "missing-braces"
   ,  "missing-field-initializers"
   ,  "missing-noreturn"
   ,  "missing-prototypes"
   ,  "name-length-exceeded"
   ,  "newline-eof"
   ,  "no-such-warning"
   ,  "non-virtual-dtor"
   ,  "object-layout-change"
   ,  "old-style-cast"
   ,  "overloaded-virtual"
   ,  "padded"
   ,  "parentheses"
   ,  "pedantic"
   ,  "pointer-sign"
   ,  "return-type"
   ,  "shadow"
   ,  "shift-sign-overflow"
   ,  "shorten-64-to-32"
   ,  "sign-compare"
   ,  "sign-conversion"
   ,  "signed-unsigned-compare"
   ,  "static-ctor-not-thread-safe"
   ,  "switch"
   ,  "switch-enum"
   ,  "this-used-in-init"
   ,  "undef"
   ,  "uninitialized"
   ,  "unknown-pragmas"
   ,  "unreachable-code"
   ,  "unreachable-code-return"
   ,  "unsafe-conversion"
   ,  "unused-but-set-variable"
   ,  "unused-function"
   ,  "unused-label"
   ,  "unused-parameter"
   ,  "unused-value"
   ,  "unused-variable"
   ,  "used-but-marked-unused"
   ,  "weak-vtables"
   ,  "arc-bridge-casts-disallowed-in-nonarc"
   ,  "arc-repeated-use-of-weak"
   ,  "deprecated-implementations"
   ,  "duplicate-method-match"
   ,  "explicit-ownership-type"
   ,  "implicit-atomic-properties"
   ,  "implicit-retain-self"
   ,  "objc-missing-property-synthesis"
   ,  "objc-root-class"
   ,  "protocol"
   ,  "receiver-is-weak"
   ,  "selector"
   ,  "strict-selector-match"
   ,  "undeclared-selector"
   }

-- Write header
function header(file)
   file:write("/* \n")
   file:write(" * squelch ver. " .. vers() .. "\n")
   file:write(" * \n")
   file:write(" * This file was auto-magically generated.\n")
   file:write(" */ \n\n")
end

-- Start switch
function initialize_switch(file)
   file:write("#undef SQUELCH_SWITCH_ENABLE_\n\n")
   file:write("#if defined(SQUELCH_SWITCH_ENABLE_)\n")
   file:write("   #error Should not get here\n")
end

-- End switch
function finalize_switch(file)
   file:write("#endif\n")
end

-- Generate push file
function generate_push(dir)
   file = io.open(dir .. "/push", "w");
   header(file)

   initialize_switch(file)
   for i = 1, #compilers do
      comp = compilers[i]
      file:write("#elif defined(" .. comp.prep[1] .. ")\n")
      file:write("   " .. comp.prag.push .. "\n")
   end
   finalize_switch(file)

   io.close(file)
end

-- Generate pop file
function generate_pop(dir)
   file = io.open(dir .. "/pop", "w");
   header(file)

   initialize_switch(file)
   for i = 1, #compilers do
      comp = compilers[i]
      file:write("#elif defined(" .. comp.prep[1] .. ")\n")
      file:write("   " .. comp.prag.pop .. "\n")
   end
   finalize_switch(file)

   io.close(file)
end

-- Generate warning file
function generate_warning(dir, warning)
   file = io.open(dir .. "/" .. warning, "w");
   header(file)

   initialize_switch(file)
   for i = 1, #compilers do
      comp = compilers[i]
      file:write("#elif defined(" .. comp.prep[1] .. ")\n")
      file:write("   " .. comp.prag.warn .. " \"-W" .. warning .. "\"\n")
   end
   finalize_switch(file)

   io.close(file)
end

-- Main function
function main()
   dir = "include/squelch"
   os.execute("mkdir include")
   os.execute("mkdir " .. dir)
   generate_push(dir)
   generate_pop(dir)

   for i = 1, #warnings do
      generate_warning(dir, warnings[i]);
   end
end

main()
