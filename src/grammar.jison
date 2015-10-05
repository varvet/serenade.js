%start Root

%%

Root
  : ChildList { return $1 }
  ;

ChildList
  : Child { $$ = [].concat($1) }
  | ChildList TERMINATOR Child { $$ = $1.concat($3) }
  ;

ElementIdentifier
  : AnyIdentifier { $$ = { name: $1, type: "element" } }
  | AnyIdentifier HASH AnyIdentifier { $$ = { name: $1, options: [{ name: "id", value: $3 }], type: "element" } }
  | HASH AnyIdentifier { $$ = { name: "div", options: [{ name: "id", value: $2 }], type: "element" } }
  | DOT AnyIdentifier { $$ = { name: "div", classes: [$2], type: "element" } }
  | ElementIdentifier DOT AnyIdentifier { $1.classes = ($1.classes || []).concat($3); $$ = $1 }
  ;

Element
  : ElementIdentifier { $$ = $1 }
  | Element LBRACKET RBRACKET { $$ = $1 }
  | Element LBRACKET PropertyList RBRACKET { $1.options = $3; $$ = $1 }
  | Element WHITESPACE Content { $1.children = ($1.children || []).concat($3); $$ = $1 }
  | Element INDENT ChildList OUTDENT { $1.children = ($1.children || []).concat($3); $$ = $1 }
  ;

ContentList
  : Content { $$ = [$1] }
  | ContentList WHITESPACE Content { $$ = $1.concat($3) }
  ;

Content
  : Bound { $$ = { type: "content", arguments: [{ value: $1, bound: true }] } }
  | STRING_LITERAL { $$ = { type: "content", arguments: [{ value: $1 }] } }
  ;

Child
  : Element { $$ = $1 }
  | IfInstruction { $$ = $1 }
  | Instruction { $$ = $1 }
  | ContentList { $$ = $1 }
  ;

PropertyList
  : Property { $$ = [$1] }
  | PropertyList WHITESPACE Property { $$ = $1.concat($3) }
  ;

Property
  : AnyIdentifier EQUALS PropertyArgument { $3.name = $1; $$ = $3 }
  | AnyIdentifier COLON Property { $3.scope = $1; $$ = $3 }
  ;

PropertyArgument
  : AnyIdentifier { $$ = { bound: true, value: $1 } }
  | Bound { $$ = { bound: true, value: $1 } }
  | AnyIdentifier BANG { $$ = { bound: true, value: $1, preventDefault: true } }
  | Bound BANG { $$ = { bound: true, value: $1, preventDefault: true } }
  | STRING_LITERAL { $$ = { value: $1 } }
  ;

InstructionIdentifier
  : VIEW { $$ = { children: [], type: "view" } }
  | COLLECTION { $$ = { children: [], type: "collection" } }
  | UNLESS { $$ = { children: [], type: "unless" } }
  | IN { $$ = { children: [], type: "in" } }
  | IDENTIFIER { $$ = { children: [], type: $1 } }
  ;

Instruction
  : DASH WHITESPACE InstructionIdentifier { $$ = $3 }
  | DASH WHITESPACE InstructionIdentifier WHITESPACE InstructionArgumentList { $3.arguments = ($3.arguments || []).concat($5); $$ = $3 }
  | Instruction INDENT ChildList OUTDENT { $1.children = $3; $$ = $1 }
  ;

IfInstruction
  : DASH WHITESPACE IF WHITESPACE InstructionArgumentList { $$ = { children: [], arguments: $5, type: "if" } }
  | IfInstruction INDENT ChildList OUTDENT { $1.children = $3; $$ = $1 }
  | IfInstruction ElseInstruction { $1.else = $2; $$ = $1 }
  ;

ElseInstruction
  : DASH WHITESPACE ELSE INDENT ChildList OUTDENT { $$ = { arguments: [], children: $5, type: "else" } }
  ;

InstructionArgumentList
  : InstructionArgument { $$ = [$1] }
  | InstructionArgumentList WHITESPACE InstructionArgument { $$ = $1.concat($3) }
  ;

InstructionArgument
  : Bound { $$ = { value: $1, bound: true } }
  | STRING_LITERAL { $$ = { value: $1 } }
  ;

AnyIdentifier
  : VIEW { $$ = $1 }
  | COLLECTION { $$ = $1 }
  | IF { $$ = $1 }
  | UNLESS { $$ = $1 }
  | IN { $$ = $1 }
  | IDENTIFIER { $$ = $1 }
  ;

Bound
  : AT AnyIdentifier { $$ = "@" + $2 }
  | DOLLAR AnyIdentifier { $$ = $2 }
  | AT { $$ = "this" }
  ;
