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

  uint256 randOffset;
  string private baseURI;

  bool public riftOpen = false;
  bool public claimed = false; //check if "team" has already claimed
  uint256 public constant ASTRONAUTS = 250;
  uint256 public constant WALLETLIMIT = 1; //NEEDED?
  uint256 public constant TEAMCLAIMAMOUNT = 10; //NEEDED?
  uint256 public constant REGULAR_COST = 0.04 ether; //MINT PRICE FOR REGULAR MINTER
  mapping(address => uint) public addressClaimed; //Keep Track of claim amount per addy if needed


  // ABASHO COLLECTIVE //
  address public AbashoContract = 0xE9C79B33C3A06f5Ae7369599F5a1e2FF886e17F0; //
  uint256 public constant ABASHO_COST = 0.01 ether; //MINT PRICE FOR ABASHO HOLDER
  mapping(uint256=>bool) public abashoClaimed; //Mapping to check if Abasho ID has already claimed their "coupon code"


  constructor() ERC721A("The Lost Astronauts", "LOST") { //Token NAME SUBJECT TO CHANGE
  }

  // Start at token 1 instead of 0
  function _startTokenId() internal view virtual override returns (uint256) {
      return 1;
  }

  //STARTS MINT
  function openRift() external onlyOwner { 
      riftOpen = true;
  }

  //ABASHO MINT FUNCTION
  function abashoRecoverAstronaut(uint256 _abashoId) external payable { //MINT FUNCTION
    IERC721 abasho = IERC721(AbashoContract); //Abasho Interface
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

  //REGULAR MINT FUNCTION
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

  //PseudoRandomiser
  function pseudoRandom() external onlyOwner{ //onlyowner
        string memory salt = "LostAstronauts";
        uint256 number = uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender,salt))) % 250;
        number == 0 ? number++: number;
        randOffset = number;
    }

  //Set BaseURI
  function setSignal(string memory baseURI_) external onlyOwner { 
      baseURI = baseURI_;
  }
  //Call BaseURI
  function _baseURI() internal view virtual override returns (string memory) {
      return baseURI;
  }
  
  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), "No Astronaut with that ID exists");

    uint256 _curId =  _tokenId + randOffset;
    if (_curId > ASTRONAUTS) {
            _curId = _curId - ASTRONAUTS;
        }
  
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _toString(_curId), '.json'))
        : '';
  }

  //withdraw funds from Smart Contract if you are the owner of Smart Contract
  function withdraw() external onlyOwner{
        payable(_msgSender()).transfer(address(this).balance);
    }
}