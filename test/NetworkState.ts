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


import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";
import { expect } from "chai";

/**
 * Test for the NetworkState contract
 */
describe("NetworkState", function () {
  let accounts: Signer[];
  let NetworkState: Contract;

  /**
   * Before each test, we deploy a new NetworkState contract.
   */
  beforeEach(async function () {
    // Get the list of signers provided by Hardhat
    accounts = await ethers.getSigners();

    // Deploy a new NetworkState contract for each test
    const NetworkStateFactory = await ethers.getContractFactory("NetworkState");
    NetworkState = await NetworkStateFactory.deploy();
    await NetworkState.deployed();
  });

  /**
   * Test case: Check the contract owner after deployment
   * Expectation: The contract owner should be the account that deployed the contract
   */
  it("Should set the right owner", async function () {
    expect(await NetworkState.owner()).to.equal(await accounts[0].getAddress());
  });

  /**
   * Test case: Mint a new territory
   * Expectation: The territory should be minted correctly and its details should be set as expected
   */
  it("Should mint a territory correctly", async function () {
    await NetworkState.connect(accounts[0]).mintTerritory(1, "Territory 1", ethers.utils.parseEther("1"));
    expect((await NetworkState.territories(1)).exists).to.equal(true);
  });

  /**
   * Test case: Attempt to mint a territory from an account that is not the owner
   * Expectation: The transaction should be reverted
   */
  it("Should not allow non-owners to mint territories", async function () {
    await expect(
      NetworkState.connect(accounts[1]).mintTerritory(2, "Territory 2", ethers.utils.parseEther("1"))
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  /**
   * Test case: User joins the community
   * Expectation: The user should be able to join the community and their details should be set as expected
   */
  it("Should allow a user to join the community", async function () {
    await NetworkState.connect(accounts[1]).joinCommunity();
    expect((await NetworkState.members(await accounts[1].getAddress())).exists).to.equal(true);
  });

  /**
   * Test case: A user attempts to join the community twice
   * Expectation: The transaction should be reverted
   */
  it("Should not allow a member to join twice", async function () {
    await NetworkState.connect(accounts[1]).joinCommunity();
    await expect(NetworkState.connect(accounts[1]).joinCommunity()).to.be.revertedWith("Member already exists");
  });
});
