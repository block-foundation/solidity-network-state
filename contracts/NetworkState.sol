// SPDX-License-Identifier: Apache-2.0


// Copyright 2023 Stichting Block Foundation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


pragma solidity ^0.8.19;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// ============================================================================
// Contracts
// ============================================================================

/**
 * @title NetworkState
 * @dev This contract manages territories as ERC20 tokens and allows for community-based governance 
 * and crowdfunding for purchasing territories. 
 */
contract NetworkState is ERC20, Ownable {
    using SafeMath for uint256;

    struct Territory {
        uint256 id;
        string name;
        uint256 price;
        bool exists;
        bool proposed;
        uint256 votes;
    }

    struct Member {
        uint256 reputation;
        bool exists;
    }

    mapping(uint256 => Territory) public territories;
    mapping(address => Member) public members;

    uint256 public crowdfundingBalance = 0;
    uint256 public totalReputation = 0;

    constructor() ERC20("NetworkState", "TT") {}

    /**
     * @dev Allows the owner to create new territories.
     * @param _id The id of the territory.
     * @param _name The name of the territory.
     * @param _price The price of the territory.
     */
    function mintTerritory(uint256 _id, string memory _name, uint256 _price) public onlyOwner {
        require(!territories[_id].exists, "Territory already exists");

        territories[_id] = Territory(_id, _name, _price, true, false, 0);
        _mint(address(this), _price);
    }

    /**
     * @dev Allows a new member to join the community.
     */
    function joinCommunity() public {
        require(!members[msg.sender].exists, "Member already exists");

        members[msg.sender] = Member(0, true);
    }

    /**
     * @dev Allows members to contribute funds to a crowdfunding pool for territory purchases.
     */
    function contributeToCrowdfunding() public payable {
        require(members[msg.sender].exists, "Only members can contribute");

        crowdfundingBalance = crowdfundingBalance.add(msg.value);

        // Reputation increases by 1 point for each Ether contributed
        uint256 reputationIncrease = msg.value / 1 ether;
        members[msg.sender].reputation = members[msg.sender].reputation.add(reputationIncrease);
        totalReputation = totalReputation.add(reputationIncrease);
    }

    /**
     * @dev Allows members to propose a territory for purchase.
     * @param _id The id of the territory to propose for purchase.
     */
    function proposeTerritory(uint256 _id) public {
        require(territories[_id].exists, "Territory does not exist");
        require(crowdfundingBalance >= territories[_id].price, "Not enough funds");

        territories[_id].proposed = true;
    }

    /**
     * @dev Allows members to vote for a proposed territory.
     * @param _id The id of the territory to vote for.
     */
    function voteForTerritory(uint256 _id) public {
        require(members[msg.sender].exists, "Only members can vote");
        require(territories[_id].proposed, "Territory not proposed for purchase");

        territories[_id].votes = territories[_id].votes.add(members[msg.sender].reputation);
    }

    /**
     * @dev Allows the owner to purchase a territory if it has been proposed and voted on by the community.
     * @param _id The id of the territory to purchase.
     */
    function buyTerritory(uint256 _id) public onlyOwner {
        require(territories[_id].exists, "Territory does not exist");
        require(territories[_id].proposed, "Territory not proposed for purchase");
        require(territories[_id].votes > totalReputation / 2, "Not enough votes");

        _transfer(address(this), owner(), territories[_id].price);

        crowdfundingBalance = crowdfundingBalance.sub(territories[_id].price);

        // Distribute territory tokens to all members based on their reputation
        for (uint256 i = 0; i < members.length; i++) {
            uint256 memberShare = territories[_id].price.mul(members[i].reputation).div(totalReputation);
            _transfer(address(this), members[i], memberShare);
        }
    }

    /**
     * @dev Allows the owner to sell a territory.
     * @param _id The id of the territory to sell.
     */
    function sellTerritory(uint256 _id) public onlyOwner {
        require(territories[_id].exists, "Territory does not exist");
        uint256 territoryBalance = balanceOf(address(this));

        _transfer(address(this), owner(), territoryBalance);
        payable(address(this)).transfer(territoryBalance);
    }
}
