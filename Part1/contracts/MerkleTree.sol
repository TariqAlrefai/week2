//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 public depth = 3;
    uint256 public leaves = 2**depth;

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        uint32 i; 
        for (i=0; i<leaves;i++){
            hashes.push(0);
        }

        for (i=0;i<(2**depth-1);i++){
            hashes.push(PoseidonT3.poseidon([hashes[i*2],hashes[i*2+1]]));
        }
        root = hashes[hashes.length-1];
    }
    
    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree

        hashes[index] = hashedLeaf;
        uint32 i;
        for (i=0;i<(2**depth-1);i++){
            hashes[i+leaves] = (PoseidonT3.poseidon([hashes[i*2],hashes[i*2+1]]));
        }

        ++index;
        root  = hashes[hashes.length-1];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        if (super.verifyProof(a,b,c,input) && input[0] == root) {
            return true;
        }
        return false;
    }
}
