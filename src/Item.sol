pragma solidity ~0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Item is ERC721("Item", "IM") {
    enum Type {
        SABLE,
        ELDERS_STICK,
        ARMOUR,
        BRACE
    }
}