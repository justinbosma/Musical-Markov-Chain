# Musical-Markov-Chain

Probabilistic music generator based on ideas from Iannis Xenakis'  “Formalized Music” and David Lewin's ideas on pitch intervals sets. This was my first attempt at making something other than a simple synth in SuperCollider. 

The first block of code creates six randomly generated melodies of midi notes, all varying in size.

The second block takes in the random midi sequences, subtracts notes that are next to each other in the sequence, e.g. given notes n1, n2, n3, the function would calculate the pitch interval distance for n2 – n1 and n3 – n2. The output will be one size smaller.  This set of array is used to calculate the probability of moving to each state (melody). Another approach to this technique could be getting the distance between each note and every other, taking into account their position in relation to the others. 

The third block creates the weights for each transition. Each array has six elements, each of which corresponds to moving to that state. Three in the first index of an array and one's in all the other positions will have a higher probability of moving to state one.

The final function takes in the weight arrays and for each generates new arrays to be used by the choose function. If there is a three in the first index, the function will add “0” to the array threes times. 

To run the program: Run each chunk of code individually, the three small lines which run the functions on a variable, then run the Pfsm which acts as the Markov Chain and creates music.

The music itself is very Kings Questy, more than likely having to do with the default synth in the Psfm. 
