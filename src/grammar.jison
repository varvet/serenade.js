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
  : AnyIdentifier { $$ = { name: $1, classes: [] } }
  | AnyIdentifier HASH AnyIdentifier { $$ = { name: $1, id: $3, classes: [] } }
  | HASH AnyIdentifier { $$ = { name: "div", id: $2, classes: [] } }
  | DOT AnyIdentifier { $$ = { name: "div", classes: [$2] } }
  | ElementIdentifier DOT AnyIdentifier { $1.classes.push($3); $$ = $1 }
  ;

Element
  : ElementIdentifier { $$ = { name: $1.name, id: $1.id, classes: $1.classes, properties: [], children: [], type: "element" } }
  | Element LBRACKET RBRACKET { $$ = $1 }
  | Element LBRACKET PropertyList RBRACKET { $1.properties = $3; $$ = $1 }
  | Element WHITESPACE Content { $1.children = $1.children.concat($3); $$ = $1 }
  | Element INDENT ChildList OUTDENT { $1.children = $1.children.concat($3); $$ = $1 }
  ;

ContentList
  : Content { $$ = [$1] }
  | ContentList WHITESPACE Content { $$ = $1.concat($3) }
  ;

Content
  : Bound { $$ = { type: "content", value: $1, bound: true } }
  | STRING_LITERAL { $$ = { type: "content", value: $1 } }
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
  : VIEW { $$ = { children: [], arguments: [], type: "view" } }
  | COLLECTION { $$ = { children: [], arguments: [], type: "collection" } }
  | UNLESS { $$ = { children: [], arguments: [], type: "unless" } }
  | IN { $$ = { children: [], arguments: [], type: "in" } }
  | IDENTIFIER { $$ = { children: [], arguments: [], type: "helper", command: $3 } }
  ;

Instruction
  : DASH WHITESPACE InstructionIdentifier { $$ = $3 }
  | DASH WHITESPACE InstructionIdentifier WHITESPACE InstructionArgumentList { $3.arguments = $5; $$ = $3 }
  | Instruction INDENT ChildList OUTDENT { $1.children = $3; $$ = $1 }
  ;

HelperArgument
  : Bound { $$ = { value: $1, bound: true } }
  | AnyIdentifier { $$ = { value: $1, static: true } }
  | STRING_LITERAL { $$ = { value: $1 } }
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
