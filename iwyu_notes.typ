#set page(paper: "presentation-16-9")
#set text(font: "Roboto", fallback: false)

#show link: underline
#show link: set text(blue)

#import "template.typ": frontpage, slide, codelistinggray

#set rect(stroke: none, fill: codelistinggray)

#frontpage(
  title: "Include what you use",
  author: "Martin Divak",
  role: "Software Engineering Consultant"
)

#slide(title: "What is it?")[
#text(weight: "bold", "Goal: Address transative dependencies and include order dependencies.")

https://github.com/include-what-you-use/include-what-you-use

IWYU (include-what-you-use) is a LLVM external tool.

Enforces `#include` in source code files for symbols used.

Removes `#include` containing symbols that are not used.

Provides configurability of mapping symbols and includes to what is enforced to be included.
]

#slide(title: "Why it matters?")[
General guidance for C++ exists. @CppCoreGuidelinesSourceFiles
#list(
  [Avoid cyclic dependencies],
  [Headers should be self contained],
  [Use headers for all declarations used in multiple files]
)

Architectural objectives in automotive and aviation standards. @FuSa @DO178

Having well managed dependencies makes a lot of other maintenance or development work easier. @EffectiveLegacy

In larger scale projects it is even more important to manage physical dependencies. @LargeScaleCpp
]

#slide(title: "How does it work?")[
IWYU uses the same libraries as Clang compiler.

Abstract Syntax Tree is a representation of source code that is closer to how a compiler can see the code. The root of these trees is the Translation Unit.

Translation Unit is the result of resolving pre-processing in source files.

The Clang libraries can keep track of what statements and declarations come from which files that are part of the same AST.

Default source code in https://compiler-explorer.com/

#grid(columns: 2, gutter: 20pt,
  rect[
    ```cpp
    int square(int num) {
        return num * num;
    }
    ```
  ],
  rect[
    ```ast
    TranslationUnitDecl
    `-FunctionDecl <line:2:1, line:4:1> line:2:5 square 'int (int)'
      |-ParmVarDecl <col:12, col:16> col:16 used num 'int'
      `-CompoundStmt <col:21, line:4:1>
        `-ReturnStmt <line:3:5, col:18>
          `-BinaryOperator <col:12, col:18> 'int' '*'
            |-ImplicitCastExpr <col:12> 'int' <LValueToRValue>
            | `-DeclRefExpr <col:12> 'int' lvalue ParmVar 0xc7b5548 'num' 'int'
            `-ImplicitCastExpr <col:18> 'int' <LValueToRValue>
              `-DeclRefExpr <col:18> 'int' lvalue ParmVar 0xc7b5548 'num' 'int'
    ```
  ]
)
]

#slide(title: "Mappings")[
  JSON style format to specify which header is the intended and documented interface header to enforce to include instead of detail header where symbol may actually be declared.
  
  #link("https://github.com/include-what-you-use/include-what-you-use/blob/master/docs/IWYUMappings.md")[From IWYU docs:]
  
  GCC `std::unique_ptr<T>` is declared in `<bits/unique_ptr.h>` but the intended interface header for that symbol is `<memory>`.

  Include mapping in a `.imp` file.
  #grid(columns: 1,
  rect[
    ```json
    { include: ["<bits/unique_ptr.h>", "private", "<memory>", "public"] }
    ```
  ]
  )

  Also specific symbol mappings is supported.
  #grid(columns: 1,
  rect[
    ```json
    { symbol: ["NULL", "private", "<cstddef>", "public"] }
    ```
  ]
  )
  
  IWYU provides several mappings that may be used with or without modification and can use project specific mappings.
]

#slide(title: "Mappings")[
  If using third party library

#rect[
```cpp
extern "C"
{
#include <libavcodec/avcodec.h>
#include <libavcodec/codec.h>
#include <libavcodec/packet.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libavutil/error.h>
#include <libavutil/frame.h>
#include <libavutil/imgutils.h>
#include <libavutil/mem.h>
#include <libavutil/pixdesc.h>
#include <libavutil/pixfmt.h>
#include <libavutil/timestamp.h>
}
```
]

Can we just add our own `ffmpeg.imp`?

#rect[
```json
...
{ include: ["<libavcodec/codec.h>", "private", "<libavutil/avcodec.h>", "public"] }
{ include: ["<libavcodec/packet.h>", "private", "<libavutil/avcodec.h>", "public"] }
...
```
]

Maybe!
]

#slide(title: "Pragmas")[
IWYU also has support for using code comments to mark specific includes as special.
  
  #link("https://github.com/include-what-you-use/include-what-you-use/blob/master/docs/IWYUPragmas.md")[Which pragma should I use?]

#text(style: "italic", "The short answer")

No. You do not need pragmas.

#text(style: "italic", "The long answer")

Bugs and ambiguity exist.

Force IWYU to keep an include.
#rect[
```cpp
#include "needed/but/is/not/needed.h" // IWYU pragma: keep
```
]

Tell IWYU "this" header is a provider/facade/interface header.
#rect[
```cpp
#include "some/detail/header.h" // IWYU pragma: export
```
]
]

#slide(title: "Restrictions, Assumptions, Limitations")[
  Implementation-Interface Correspondence Inherited from Google.

  File extensions are not standardized. Usually `.h`, `.hpp`, and `.hh`.
  
  Whether to use C++ or C style headers for C libraries. Example headers `<cstdint>` or `<stdint.h>` respectively.
  
  No 1.0 release yet.

  `IWYUMappings.md` and `IWYUPragmas.md` have been mentioned. See also `WhyIWYU.md`, `WhyIWYUIsDifficult.md`, and `IWYUFAQ.md`.

  See also open issues in the repository.
]

#slide(title: "Can including/importing code be improved?")[
  Macros do not obey scope and type rules, make what human programmer and compiler see very different, and seriously constrain tool building. @ModulesAndMacros

C++20 Modules seem fantastic but I have not used them yet.
]

#bibliography(style: "ieee", "iwyu_notes.bib")
