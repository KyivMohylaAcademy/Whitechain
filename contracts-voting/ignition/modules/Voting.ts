import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import VotingRegistryModule from "./VotingRegistry";

const VotingModule = buildModule("VotingModule", (m) => {
  const votingRegistry = m.useModule(VotingRegistryModule).votingRegistry

  const votingToken = m.contract("ERC20VotingToken", ["Shabashab's Voting Token", "SVT"])
  const votingTokenMarketplace = m.contract("ERC20VotingTokenMarketplace", [votingToken, (10n ** 16n)])
  const votingContract = m.contract("VotingContract", [votingToken, (10n ** 14n), votingRegistry])

  m.call(votingToken, "setMarketplaceAddress", [votingTokenMarketplace])
  m.call(votingRegistry, "addVotingContract", [votingContract])

  return {
    votingToken,
    votingTokenMarketplace,
    votingContract,
  }
})

export default VotingModule;