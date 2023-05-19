// SPDX-License-Identifier: MIT
pragma solidity ^0.9.0;

contract Lottery {
    address public manager;
    address[] public players;

    constructor() {
        manager = 0xfe23171e489f47CBC8C1e225384b02164318F23F; //Change this to your address when you deploy to call the pickWinners function
    }

    // Enter the lottery with a custom amount of Pulse and get taxed 10% 
function enter() public payable {
    require(msg.value > 0, "You must send some Pulse to enter.");
    
    uint256 managerCommission = msg.value / 10;
    
    // Transfer 10% of the entry value to the manager
    (bool success, ) = payable(manager).call{value: managerCommission}("");
    require(success, "Transfer failed.");

    // The remainder of the entry fee becomes the player's actual deposit
    players.push(msg.sender);
}

    // Random function takes the block difficulty, timestamp, and number of players, shuffles them and produces a number (later used to select winners)
    function random() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }
    
    // Pick winner function to select a random winner and transfer the balance of the contract to them
    function pickWinner() public {
        require(msg.sender == manager, "Only manager can pick the winner.");
        require(players.length > 0, "No players joined the lottery.");

        uint256 index = random() % players.length;
        address payable winner = payable(players[index]);

        uint256 contractBalance = address(this).balance;
        winner.transfer(contractBalance);

        players = new address[](0);
    }

    function pot() public view returns (uint256) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }
}
