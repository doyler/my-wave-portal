// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s has waved!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
         * Generate a new seed for the next user that sends a wave
         */

        /*
         * Here, I take two numbers given to me by Solidity, block.difficulty and block.timestamp and combine them to create a random number.
         * block.difficulty tells miners how hard the block will be to mine based on the transactions in the block.
         * Blocks get harder for a # of reasons, but, mainly they get harder when there are more transactions in the block
         *      (some miners prefer easier blocks, but, these payout less).
         * block.timestamp is just the Unix timestamp that the block is being processed.
         * These #s are pretty random. But, technically, both block.difficulty and block.timestamp could be controlled by a sophisticated attacker.
         * To make this harder, I create a variable seed that will essentially change every time a user sends a new wave.
         * So, I combine all three of these variables to generate a new random seed.
         * Then I just do % 100 which will make sure the number is brought down to a range between 0 - 99.
         * It's important to see here that an attack could technically game your system here if they really wanted to.
         * It'd just be really hard.
         * There are other ways to generate random numbers on the blockchain but Solidity doesn't natively give us anything
         *      reliable because it can't! All the #s our contract can access are public and never truly random.
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}