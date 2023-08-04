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



// Import necessary libraries
import { ethers, upgrades } from "hardhat";

/**
 * Asynchronous function to deploy the NetworkState contract.
 */
async function main() {
  // Get the ContractFactory for the NetworkState contract
  // The ContractFactory allows us to create instances of contracts
  const NetworkStateFactory = await ethers.getContractFactory("NetworkState");

  console.log("Starting deployment...");

  // Deploy the contract and wait for it to be mined
  // This will deploy the contract to the network specified in the Hardhat configuration,
  // and the account specified in the .env file
  const NetworkState = await NetworkStateFactory.deploy();

  console.log("Contract deployed, waiting for transaction confirmation...");

  // Wait for the transaction to be confirmed
  await NetworkState.deployTransaction.wait();

  console.log("Transaction confirmed.");

  // Log the address where the contract was deployed
  console.log("NetworkState deployed to:", NetworkState.address);
}

/**
 * Executes the main function and handles any errors.
 */
main()
  .then(() => process.exit(0)) // Exit successfully
  .catch((error) => {
    console.error(error); // Log the error
    process.exit(1); // Exit with failure
  });
