 TrustVote Smart Contract

 Overview
**TrustVote** is a decentralized voting smart contract built on the Stacks blockchain. It enables transparent, secure, and immutable voting for any community or DAO-based governance system. TrustVote ensures that all proposals, votes, and outcomes are recorded on-chain with verifiable results.

 Features
-  Create new proposals with voting deadlines
-  Cast votes (yes/no) for proposals
-  Prevents double voting
-  Tally votes to determine proposal outcomes
-  Read-only functions to query proposals and voting status

 Functions

 Public Functions
- `create-proposal (description (string-utf8 100)) (duration uint)`: Create a new proposal with a description and voting period.
- `vote (proposal-id uint) (support bool)`: Vote yes (true) or no (false) on a proposal.
- `tally-votes (proposal-id uint)`: Calculate and finalize the outcome of a proposal after the voting period.

 Read-Only Functions
- `get-proposal (proposal-id uint)`: Retrieve full details of a specific proposal.
- `has-voted (proposal-id uint) (voter principal)`: Check if a specific voter has already voted on a proposal.

 Usage
Deploy the contract on the Stacks blockchain using Clarity tools such as Clarinet. After deployment, interact with the contract using Stacks blockchain SDKs or wallets that support contract calls.

 Installation
To clone and test:
```bash
git clone https://github.com/your-org/trust-vote.git
cd trust-vote
clarinet test
