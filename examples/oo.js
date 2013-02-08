// Define our person, we extend Serenade.Model
var Person = Serenade.Model.extend();
Person.property("name");

// Define a controller
var GreetingController = function(person) {
  this.person = person;
};
GreetingController.prototype.greet = function() {
  alert("Hello! " + this.person.name)
};

// Instantiate a person
var jonas = new Person({ name: "Jonas" });

// Pass in our person and the controller constructor
// Serenade will instantiate the controller for you.
var element = Serenade.render("greet", jonas, GreetingController);

document.body.appendChild(element);
