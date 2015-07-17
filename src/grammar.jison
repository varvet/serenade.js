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
  | Helper { $$ = $1 }
  | ContentList { $$ = $1 }
  ;

PropertyList
  : Property { $$ = [$1] }
  | PropertyList WHITESPACE Property { $$ = $1.concat($3) }
  ;

Property
  : AnyIdentifier EQUALS AnyIdentifier { $$ = { name: $1, static: true, value: $3, scope: "attribute" } }
  | AnyIdentifier EQUALS Bound { $$ = { name: $1, value: $3, bound: true, scope: "attribute" } }
  | AnyIdentifier EQUALS AnyIdentifier BANG { $$ = { name: $1, static: true, value: $3, scope: "attribute", preventDefault: true } }
  | AnyIdentifier EQUALS Bound BANG { $$ = { name: $1, value: $3, bound: true, scope: "attribute", preventDefault: true } }
  | AnyIdentifier EQUALS STRING_LITERAL { $$ = { name: $1, value: $3, scope: "attribute" } }
  | AnyIdentifier COLON Property { $3.scope = $1; $$ = $3 }
  ;

Instruction
  : DASH WHITESPACE VIEW WHITESPACE STRING_LITERAL { $$ = { children: [], type: "view", argument: $5 } }
  | DASH WHITESPACE VIEW WHITESPACE Bound { $$ = { children: [], type: "view", argument: $5, bound: true } }
  | DASH WHITESPACE COLLECTION WHITESPACE Bound { $$ = { children: [], type: "collection", argument: $5 } }
  | DASH WHITESPACE UNLESS WHITESPACE Bound { $$ = { children: [], type: "unless", argument: $5 } }
  | DASH WHITESPACE IN WHITESPACE Bound { $$ = { children: [], type: "in", argument: $5 } }
  | Instruction INDENT ChildList OUTDENT { $1.children = $3; $$ = $1 }
  ;

Helper
  : DASH WHITESPACE IDENTIFIER { $$ = { command: $3, arguments: [], children: [], type: "helper" } }
  | Helper WHITESPACE HelperArgument { $1.arguments.push($3); $$ = $1 }
  | Helper INDENT ChildList OUTDENT { $1.children = $3; $$ = $1 }
  ;

HelperArgument
  : Bound { $$ = { value: $1, bound: true } }
  | AnyIdentifier { $$ = { value: $1, static: true } }
  | STRING_LITERAL { $$ = { value: $1 } }
  ;

IfInstruction
  : DASH WHITESPACE IF WHITESPACE Bound { $$ = { children: [], type: "if", argument: $5 } }
  | IfInstruction INDENT ChildList OUTDENT { $1.children = $3; $$ = $1 }
  | IfInstruction ElseInstruction { $1.else = $2; $$ = $1 }
  ;

ElseInstruction
  : DASH WHITESPACE ELSE INDENT ChildList OUTDENT { $$ = { arguments: [], children: $5, type: "else" } }
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
  : AT AnyIdentifier { $$ = $2 }
  | AT { $$ = undefined }
  ;
