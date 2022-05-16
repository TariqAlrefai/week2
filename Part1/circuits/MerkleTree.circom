pragma circom 2.0.0;


include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";



template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n]; // Create an array conaning all the leaves.
    signal output root; // The root is the output

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves

    signal nodes[2**n-1]; // creat an array conaning all the nodes
    
    var numHashedLeaves = (2**n)/2;
    var numHashedNodes = (2**n)/2-1;
    
    component hasher[numHashedLeaves]; // creating a component to hash the leaves. (2**n)/2
    component hasher1[(2**n)/2-1]; // creating a component to hash the nodes.


    // Hashing all the leaves, then store them in the node array. (Only first layer 'leaves')
    var i; 
    for (i=0; i<(numHashedLeaves); i++){ 
        hasher[i]= Poseidon(2);  // Making several poseidon for each hasher
        hasher[i].inputs[0] <== leaves[i*2]; // hashing the element from leaves.
        hasher[i].inputs[1] <== leaves[(i*2)+1]; // hashing next element from leaves.

        nodes[i] <== hasher[i].out; // storing the output of the hasher object to the nodes array. 
    }

    // now, hashing the nodes above the hashed leaves. 
    for (i=0; i<((numHashedNodes)); i++){
        hasher1[i]= Poseidon(2); // Making several poseidon for each hasher
        hasher1[i].inputs[0] <== nodes[i*2]; // hashing the element from Nodes.
        hasher1[i].inputs[1] <== nodes[(i*2)+1]; // hashing next element from Nodes.                                                                                                                                        
        // storing the output from the ending of the last element stored as node (hashed leave)
        nodes[(2**n)/2+i] <== hasher1[i].out; 
    }

    root <== nodes[2**n-2]; // storing the last element from nodes array to the root. 
    
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    
    component hashers[n];
    component mux[n];

    signal levelHashes[n + 1];

    levelHashes[0] <== leaf;

    for (var i = 0; i < n; i++) {
        // Should be 0 or 1
        path_index[i] * (1 - path_index[i]) === 0;

        hashers[i] = HashLeftRight();
        mux[i] = MultiMux1(2);

        mux[i].c[0][0] <== levelHashes[i];
        mux[i].c[0][1] <== path_elements[i];
        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== levelHashes[i];

        mux[i].s <== path_index[i];
        hashers[i].left <== mux[i].out[0];
        hashers[i].right <== mux[i].out[1];

        levelHashes[i + 1] <== hashers[i].out;
    }

    root <== levelHashes[n];
}


template HashLeftRight() {
    signal input left;
    signal input right;

    signal output out;

    component hasher = PoseidonHash();
    left ==> hasher.inputs[0];
    right ==> hasher.inputs[1];

    out <== hasher.out;
}


template PoseidonHash() {
    var nInputs = 2;
    signal input inputs[nInputs];
    signal output out;

    component hasher = Poseidon(nInputs);
    for (var i = 0; i < nInputs; i ++) {
        hasher.inputs[i] <== inputs[i];
    }
    out <== hasher.out;
}