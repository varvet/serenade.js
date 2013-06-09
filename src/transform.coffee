class Map
  constructor: (array) ->
    @map = {}
    @putIn(index, element) for element, index in array
    @map

  isMember: (element) ->
    if @map[hash(element)]?[0].length > 0
      @map[hash(element)][0].shift()
      true
    else
      false

  indexOf: (element) ->
    @map[hash(element)]?[0]?[0]

  putIn: (index, element) ->
    existing = @map[hash(element)]
    @map[hash(element)] = if existing
      [[index].concat(existing[0]).sort((a, b) -> a - b), element]
    else
      [[index], element]

  putAway: (element) ->
    @map[hash(element)]?[0].shift?()

Transform = (from=[], to=[]) ->
  operations = []
  to = to.map((e) -> e)
  targetMap = new Map(to)

  remove = ->
    result = []
    for element in from
      if targetMap.isMember(element)
        result.push(element)
      else
        operations.push(type: "remove", index: result.length)
    result

  insert = (cleaned) ->
    result = cleaned.map((e) -> e)
    cleanedMap = new Map(cleaned)

    for element, index in to
      unless cleanedMap.isMember(element)
        operations.push(type: "insert", index: index, value: element)
        result.splice(index, 0, element)
    result

  swap = (complete) ->
    completeMap = new Map(complete)
    for actual, indexActual in complete
      wanted = to[indexActual]

      if actual isnt wanted
        indexWanted = completeMap.indexOf(wanted)
        completeMap.putAway(actual)
        completeMap.putAway(wanted)
        completeMap.putIn(indexWanted, actual)
        complete[indexActual] = wanted
        complete[indexWanted] = actual
        operations.push(type: "swap", index: indexActual, with: indexWanted)
      else
        completeMap.putAway(actual)

  swap(insert(remove()))
  operations
