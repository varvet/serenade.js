export {
  of(value) {
    let channel = new StaticChannel();
    channel.emit(value);
    return channel;
  },

  all(parents) {
    let channel = new Channel()
    let value = () => parents.map((p) => p.value)
    parents.forEach((parent) => {
      parent.subscribe(() => channel.emit(value()));
    });
    channel.emit(value());
    return channel;
  }
}
