// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC20VotingToken
/// @author Artem Tarasenko (@shabashab)
/// @notice ERC20 token with mint and burn functions restricted to a marketplace contract.
/// @dev Inherits from OpenZeppelin's ERC20 and Ownable. Only the designated marketplace can mint or burn tokens.
contract ERC20VotingToken is ERC20, Ownable {
    /// @notice Address of the authorized marketplace contract.
    address public marketplaceAddress;

    /// @notice Error thrown when a non-authorized account calls a restricted function.
    error UnauthorizedAccount();

    /// @notice Deploys the ERC20VotingToken contract.
    /// @param name The name of the ERC20 token.
    /// @param symbol The symbol of the ERC20 token.
    /// @dev Initializes the ERC20 and Ownable contracts.
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable(_msgSender()) { }

    /// @notice Sets the address of the authorized marketplace contract.
    /// @dev Only callable by the contract owner.
    /// @param _marketplaceAddress The address of the marketplace contract.
    function setMarketplaceAddress(address _marketplaceAddress) external onlyOwner {
        marketplaceAddress = _marketplaceAddress;
    }

    /// @notice Mints new tokens to a specified address.
    /// @dev Only callable by the authorized marketplace contract.
    /// @param to The address to receive the minted tokens.
    /// @param amount The number of tokens to mint.
    function mint(address to, uint256 amount) external onlyMarketplace {
        _mint(to, amount);
    }

    /// @notice Burns tokens from a specified address.
    /// @dev Only callable by the authorized marketplace contract.
    /// @param from The address from which tokens will be burned.
    /// @param amount The number of tokens to burn.
    function burn(address from, uint256 amount) external onlyMarketplace {
        _burn(from, amount);
    }

    /// @notice Restricts function access to the authorized marketplace contract.
    /// @dev Reverts with UnauthorizedAccount if called by any other address.
    modifier onlyMarketplace {
        if(_msgSender() != marketplaceAddress) {
            revert UnauthorizedAccount();
        }
        _;
    }
}
