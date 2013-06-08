class Map
  constructor: (array) ->
    @map = {}
    @map[hash(element)] = [index, element] for element, index in array
    @map

  isMember: (element) ->
    @map[hash(element)]?

  indexOf: (element) ->
    @map[hash(element)]?[0]

  put: (index, element) ->
    @map[hash(element)] = [index, element]

class Transform
  constructor: (target) ->
    @target = target.map((e) -> e)
    @targetMap = new Map(@target)

  calculate: (origin) ->
    @operations = []
    @swap(@insert(@delete(origin)))
    @operations

  delete: (origin) ->
    result = []
    for element in origin
      if @targetMap.isMember(element)
        result.push(element)
      else
        @operations.push(type: "delete", index: result.length)
    result

  insert: (cleaned) ->
    result = cleaned.map((e) -> e)
    cleanedMap = new Map(cleaned)

    for element, index in @target
      unless cleanedMap.isMember(element)
        @operations.push(type: "insert", index: index, value: element)
        result.splice(index, 0, element)
    result

  swap: (complete) ->
    completeMap = new Map(complete)
    for actual, indexActual in complete
      wanted = @target[indexActual]

      if actual isnt wanted
        indexWanted = completeMap.indexOf(wanted)
        completeMap.put(indexActual, wanted)
        completeMap.put(indexWanted, actual)
        complete[indexActual] = wanted
        complete[indexWanted] = actual
        @operations.push(type: "swap", index: indexActual, with: indexWanted)
