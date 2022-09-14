// SPDX-License-Identifier: MIT

/*///////////////////////////////////////////////////////////////////////////////////

LOST ASTRONAUTS BY KEN KELLEHER

*////////////////////////////////////////////////////////////////////////////////////

// ABASHO COLLECTIVE DROP
// ART BY KEN KELLEHER 
// AUTHOR NODESTARQ                                                                                 

//REMOVE ALL COMMENTS BELOW HERE BEFORE MAINNET DEPLOYMENT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";

contract LostAstronauts is ERC721A, Ownable {

  uint256 private CHAINID_ONDEPLOY;
  string private baseURI;

  bool public riftOpen = false;
  bool public claimed = false; //check if "team" has already claimed
  uint256 public constant ASTRONAUTS = 250;
  uint256 public constant WALLETLIMIT = 1; //NEEDED?
  uint256 public constant TEAMCLAIMAMOUNT = 10; //NEEDED?
  uint256 public constant REGULAR_COST = 0.04 ether; //MINT PRICE FOR REGULAR MINTER
  mapping(address => uint) public addressClaimed; //Keep Track of claim amount per addy if needed


  // ABASHO COLLECTIVE //
  address public AbashoContract = 0xd9145CCE52D386f254917e481eB44e9943F39138; //
  uint256 public constant ABASHO_COST = 0.01 ether; //MINT PRICE FOR ABASHO HOLDER
  mapping(uint256=>bool) public abashoClaimed; //Mapping to check if Abasho ID has already claimed their "coupon code"


  constructor() ERC721A("The Lost Astronauts", "LOST") { //Token NAME SUBJECT TO CHANGE
    //CHAINID_ONDEPLOY = block.chainid; //Uncomment on deploy
  }

  // Start at token 1 instead of 0
  function _startTokenId() internal view virtual override returns (uint256) {
      return 1;
  }
  //Uncomment after deployment
  /*
  function isPoW() public view returns(bool){
    return CHAINID_ONDEPLOY == block.chainid;
  }
  */ 

  function abashoRecoverAstronaut(uint256 _abashoId) external payable { //MINT FUNCTION
    IERC721A abasho = IERC721A(AbashoContract); //Abasho Interface
    uint256 total = totalSupply();
    require(riftOpen, "Merge Rift did not open yet"); //Check if sale has started
    require(total + 1 <= ASTRONAUTS, "All 250 Lost Astronauts have already been rescued!"); // check if all 250 have already been minted
    require(ABASHO_COST <= msg.value, "Not enough ETH"); //check if enough ether has been sent
    require(addressClaimed[_msgSender()] + 1 <= WALLETLIMIT, "It's too dangerous, you can't go back in!"); // ONLY IF USED check if wallet limit reached
    //Abasho Checks begin here
    require(abasho.ownerOf(_abashoId) == _msgSender(), "Nobasho detected"); //check If msg.sender is abasho owner
    require(!abashoClaimed[_abashoId], "Abasho ID has already rescued a Lost Astronaut"); //check if abasho has already claimed Their 1 time Discount
    abashoClaimed[_abashoId] = true; //set abasho claimed Variable
    // PULL LOST ASTRONAUT OUT OF THE MERGE EVENT HORIZONT
    addressClaimed[_msgSender()] += 1; //MINT EVENT
    _safeMint(msg.sender, 1);
  }

  function recoverAstronaut() external payable { //MINT FUNCTION
    uint256 total = totalSupply();
    require(riftOpen, "Merge Rift did not open yet");
    require(total + 1 <= ASTRONAUTS, "All 250 Lost Astronauts have already been rescued!");
    require(REGULAR_COST <= msg.value, "Not enough ETH");
    require(addressClaimed[_msgSender()] + 1 <= WALLETLIMIT, "It's too dangerous, you can't go back in!");
    // PULL LOST ASTRONAUT OUT OF THE MERGE EVENT HORIZONT
    addressClaimed[_msgSender()] += 1; //MINT EVENT
    _safeMint(msg.sender, 1);
  }
    /*
  function teamClaim() external onlyOwner {
    require(!claimed, "Team has already claimed");
    // Transfer tokens to the TEAMWALLET
    _safeMint(TEAMWALLET, TEAMCLAIMAMOUNT);
    claimed = true;
  }
    */
  function setSignal(string memory baseURI_) external onlyOwner { //Sets BaseURI
      baseURI = baseURI_;
  }

  function _baseURI() internal view virtual override returns (string memory) {
      return baseURI;
  }

  function openRift() external onlyOwner { //STARTS MINT
      riftOpen = true;
  }
  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'There is no token with that ID');
    
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _toString(_tokenId), '.json'))
        : '';
  }

  //withdraw funds from Smart Contract
  function withdraw() external onlyOwner{
        payable(_msgSender()).transfer(address(this).balance); //Withdraw Smart Contract balance
    }
}