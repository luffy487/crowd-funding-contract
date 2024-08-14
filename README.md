# CrowdFunding Smart Contract

## Overview

The **CrowdFunding** smart contract allows users to create and manage crowdfunding campaigns on the Ethereum blockchain. It provides functionality for project creation, contributions, withdrawals, and refunds.

## Key Features

1. **Create a Project**
   - Users can create new crowdfunding projects by providing a description, fundraising goal, and deadline.
   - Each project is identified by a unique ID.

2. **Contribute to a Project**
   - Users can contribute funds to any project.
   - Contributions are tracked and added to the total amount raised for the project.
   - If the project meets its funding goal, it's marked as "goal reached."

3. **Withdraw Funds**
   - Only the creator of a project can withdraw funds.
   - Funds can only be withdrawn if the project's goal has been met and the deadline has passed.

4. **Request a Refund**
   - Contributors can request a refund if the project does not meet its goal and the funds have not been withdrawn yet.
   - Refunds return the contributed amount to the contributor.

5. **Project Information**
   - Users can check various details about a project, including:
     - Creator's address
     - Funding goal
     - Amount raised
     - Deadline
     - Whether the goal has been reached
     - Whether funds have been withdrawn

## Events

- **ProjectCreated**: Emitted when a new project is created.
- **Contributed**: Emitted when a contribution is made.
- **GoalReached**: Emitted when a project's funding goal is reached.

## Technical Details

### Solidity

- **Solidity** is a high-level programming language designed for writing smart contracts that run on the Ethereum Virtual Machine (EVM).
- The **CrowdFunding** contract is written in Solidity version `^0.8.18`.
- It utilizes Solidity features such as `structs` to manage project data, `mapping` for tracking contributions, and `modifiers` to enforce access control and validation.

### Foundry

- **Foundry** is a modern toolchain for Ethereum smart contract development, including testing, deployment, and debugging.
- It is used for building, testing, and deploying Solidity smart contracts efficiently.
- With Foundry, developers can write comprehensive tests for their smart contracts to ensure they work as expected before deployment.

---

This contract helps manage crowdfunding efforts by keeping track of contributions and ensuring that funds are only used according to the project's terms. Solidity provides the language to write the contract, while Foundry aids in the development and testing process.
