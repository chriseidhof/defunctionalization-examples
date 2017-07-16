# defunctionalization-examples

This contains some examples in Swift that I built while reading [Defunctionalization at Work](http://www.brics.dk/RS/01/23/BRICS-RS-01-23.pdf).

Interestingly, we can't defunctionalize polymorphic higher-order functions using a single enum, but we need multiple enums (one per type). We can then unify them using a protocol.
