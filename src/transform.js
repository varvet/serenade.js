import { hash } from "./helpers"

class Map {
  constructor(array) {
    this.map = {};
    array.forEach((element, index) => this.put(index, element))
  }

  isMember(key) {
    let element = this.map[hash(key)];
    return element && element[0].length > 0;
  }

  indexOf(key) {
    let element = this.map[hash(key)];
    return element && element[0] && element[0][0];
  }

  put(index, key) {
    let h = hash(key);
    let existing = this.map[h];
    if(existing) {
      this.map[h] = [existing[0].concat(index).sort((a, b) => a - b), key];
    } else {
      this.map[h] = [[index], key];
    }
  }

  remove(key) {
    let element = this.map[hash(key)];
    if(element && element[0]) {
      element[0].shift();
    }
  }
}

export default function Transform(from, to) {
  if(!from) { from = []; }
  if(!to) { to = []; }

  let operations = [];
  to = to.map((e) => e);
  let targetMap = new Map(to);
  let cleaned = [];

  from.forEach((element) => {
    if(targetMap.isMember(element)) {
      cleaned.push(element);
    } else {
      operations.push({ type: "remove", index: cleaned.length });
    }
    targetMap.remove(element);
  });

  let complete = [].concat(cleaned);

  let cleanedMap = new Map(cleaned);

  to.forEach((element, index) => {
    if (!cleanedMap.isMember(element)) {
      operations.push({ type: "insert", index: index, value: element });
      complete.splice(index, 0, element);
    }
    cleanedMap.remove(element);
  });

  let completeMap = new Map(complete);

  complete.forEach((actual, indexActual) => {
    let wanted = to[indexActual];
    if (actual !== wanted) {
      let indexWanted = completeMap.indexOf(wanted);
      completeMap.remove(actual);
      completeMap.remove(wanted);
      completeMap.put(indexWanted, actual);
      complete[indexActual] = wanted;
      complete[indexWanted] = actual;
      operations.push({ type: "swap", index: indexActual, with: indexWanted });
    } else {
      completeMap.remove(actual);
    }
  });

  return operations;
};
