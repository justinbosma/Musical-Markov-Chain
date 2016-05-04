Methods/Documented code:

s.boot;

//Output: 2d array of melodies
//Creates 2D array of 6 random midi melodies of varying size
(
f = {
    var randSize, eventArray, newArray, index1, index2;
	//eventArray: final 2d array of melodies. This is set to take in 6 melodies
    eventArray = Array.new(6);
    index1 = 0;
    while({index1 < 6}, {
		// randSize: random size for each melody array. choose from 2, 4, or 8 for issues with 			//timing
        randSize = [2,4,8].choose;
        index2 = 0;
	//individual array of midi melody
        newArray = Array.new(randSize);
        while({index2 < randSize}, {
			//using 1 octave. 69 = A above middle C
            newArray.insert(index2, rrand(69, 80));
            index2 = index2 + 1});
        eventArray.insert(index1, newArray);
        index1 = index1 + 1});
	//output
    eventArray;
};
)

// Input: 2D array of midi
// Output: 2D array of intervals
// creates 2D array of pitch intervals.
//For each array of midi, subtract the preceding note. m2-m1,  m1-m0 etc
//Each pitch interval array will be 1 unit smaller in size
(
g = {arg eventArray = [ ];//2D array of midi
	var index1, index2, interval, pitchArray, totalPitchArray, tempArray;
	totalPitchArray = Array.new(6);//totalPitchArray holds the 6 pitch interval arrays
	index1 = 0;
	index2 = 0;
	interval = 0;//holder for pitch interval

	while({index1 < 6}, {

	pitchArray = Array.new(eventArray.at(index1).size);//individual array for pitch intervals

		while({index2 < (eventArray.at(index1).size - 1)}, {
			//temporary array for storing intervals to subtract
			tempArray = eventArray.at(index1);
			//mod 12 to keep in octave
			interval = ((tempArray.at(index2 + 1) - tempArray.at(index2))%12);
			pitchArray.insert(index2, interval);
			index2 = index2 + 1;

			interval = 0;
		});

		totalPitchArray.insert(index1, pitchArray);
		index1 = index1 + 1;
		index2 = 0;
	});
	//output
	totalPitchArray;
};
)

//Input: 2D array of intervals
//Output: 2D array of weights
//creates 2D matrix of weights by comparing each interval array to everyother.
//If array B has an element of array A, add one to corresponding place in array.
//Does this for every element and every array
(
h = {arg eventArray = [];//2D array of intervals
	var arraySize, index1, index2, index3, weight, totalWeightArray, eventWeightArray;

	index1 = 0;
	weight = 0;
//Declares array for holding weights. Have to declare size, SuperCollider issue
	eventWeightArray = [0,0,0,0,0,0];
	totalWeightArray = Array.new(6);//holds arrays of weights
	while({index1 < 6}, {
		arraySize = eventArray.at(index1).size;//gets size for looping
		index2 = 0;

		while({index2 < 6}, {//loops through array holding arrays
			index3 = 0;

			while({index3 < arraySize}, {//goes through each element in interval array
				if(eventArray.at(index2).includes(eventArray.at(index1).at(index3)),
			//add 1 to total weight if element is in other array
					{weight = weight + 1},
					{weight = weight});//Else set weight to weight
				index3 = index3 + 1;
			});
		//adds weight to corresponding place in array for each state
			eventWeightArray.put(index2, weight);
			index2 = index2 + 1;
			weight = 0;
		});

		totalWeightArray.insert(index1, eventWeightArray);// adds ind state array to total array
		eventWeightArray = [0,0,0,0,0,0];
		index1 = index1 + 1;

	});
	//output
	totalWeightArray;
};
)

(
//input: 2d array of weights
//output: 2D array of integers representing probabilities
//Determines prob for events. Creates an array with sequence of numbers.
//[0,0,0,1,1,2] would imply 3/6 to get to state 0, 2/6 to get to state 1, 1/6 to get to state 2
//Pfsm uses arrays for state transitions

j = {arg weightArray;
	var index1 = 0, index2 = 0, rem, probArray, indivProbArray, subArray;
	probArray = Array.new(6);//array hold all probability arrays
	indivProbArray = [];// individual array for probabilities

	while({index1 < 6}, {//loop through array


		while({index2 < 6}, {
			subArray = weightArray.at(index1);//sets sub array to indexed array of weights

	//this loop subtracts one from the weight of the place in the array that corresponds to index2
	//and adds index2 to the indivProbArray
			while({subArray.at(index2) > 0}, {
				rem = subArray.at(index2);//set rem to remaining weight
				indivProbArray = indivProbArray.add(index2);//adds indexed number

				subArray.put(index2, rem - 1);//set array with weight - 1
			});
			index2 = index2 + 1;
		});
	//adds array of state transitions to holding array
		probArray.insert(index1, indivProbArray);
		index1 = index1 + 1;
		indivProbArray = Array.new();//resets indivProbArray
		index2 = 0;
	});
	//output
	probArray;
};
)


x = f.value;//midi arrays
a = h.(g.(x));//array of weight arrays
b = j.(a);//array of state transition arrays


(
//From Examples in help file
//Each portion marked state# is a different state. dur is the duration of each note, midinote takes in pseq which
//sequences through every midinote. b.at(#) is the array of state transition probabilities. an array like [0,0,1,2]
//has probability going to state 0 1/2, state 1 is 1/4, and state 2 is 1/4

Pfsm([
    #[3, 5], // entry states

    //e1 (== state 0)
	Pbind( \dur, 1/2, \midinote, Pseq(x.at(0)) ),//dur is duration of notes, Pseq plays midi notes in sequnce
	b.at(0),//state transition array
    //e2 (== state 1)
    Pbind( \dur, 1/2, \midinote, Pseq(x.at(1)) ),
    b.at(1),
    //e3 (== state 2)
    Pbind( \dur, 1/3, \midinote, Pseq(x.at(2)) ),
    b.at(2),
    //e4 (== state 3)
    Pbind( \dur, 1/4, \midinote, Pseq(x.at(3)) ),
    b.at(3),
    //e5 (== state 4)
    Pbind( \dur, 1/6, \midinote, Pseq(x.at(4)) ),
    b.at(4),
    //e6 (== state 5)
    Pbind( \dur, 1/4, \midinote, Pseq(x.at(5)) ),
    b.at(5),

    // terminal state
    nil, nil
]).play;
)
