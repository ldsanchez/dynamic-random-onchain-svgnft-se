// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "./SVG.sol";
import "./Utils.sol";
import "./HexStrings.sol";
import "hardhat/console.sol";

error Not__EnoughETH();
error Done__Minting();
error Token__DoesntExists();

contract DynamicRSVGNFT is ERC721Enumerable, VRFConsumerBase, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using HexStrings for uint160;

    // VRF Paramenters
    bytes32 internal immutable keyHash;
    uint256 internal immutable fee;

    // ETH Price Threshold
    uint256 public threshold;

    // SVG
    string[] private colors;
    string[] private masks;
    string[] private happySmiles;
    string[] private sadSmiles;
    uint256 public price;
    uint256 public constant limit = 100;

    AggregatorV3Interface internal immutable i_priceFeed;

    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    mapping(uint256 => uint256) public tokenIdToRandomNumber;
    mapping(uint256 => string) private smile;
    mapping(uint256 => string) private faceShape;
    mapping(uint256 => string) private shapeColor;
    mapping(uint256 => string) private faceColor;

    event SetThreshold(address sender, uint256 threshold);
    event RequestRandomNumber(
        bytes32 indexed requestId,
        uint256 indexed tokenId
    );
    event Minted(uint256 indexed tokenId);

    constructor(
        address _VRFCoordinator,
        address _LinkToken,
        address _priceFeedAddress,
        bytes32 _keyHash,
        uint256 _fee
    )
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("Dynamic Random SVG NFT", "drsvgNFT")
    {
        i_priceFeed = AggregatorV3Interface(_priceFeedAddress);
        fee = _fee;
        keyHash = _keyHash;
        price = 1000000000000000; // 0.001 ETH
        threshold = 2000000000000000000000;
        masks = ["mask__beam", "none"];
        colors = ["#FFAD08", "#EDD75A", "#73B06F", "#0C8F8F", "#405059"];
        happySmiles = [
            "M15 21c2 1 4 1 6 0",
            "M15 19c2 1 4 1 6 0",
            "M13,20 a1,0.75 0 0,0 10,0"
        ];
        sadSmiles = [
            "M15 21c2 -1 4 -1 6 0",
            "M15 19c2 -2 4 -1 5 1",
            "M13,25 a1,0.75 0 0,1 10,0"
        ];
    }

    function setThreshold(uint256 newThreshold) public {
        threshold = newThreshold;
        emit SetThreshold(msg.sender, threshold);
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function create() public payable returns (bytes32 requestId) {
        if (msg.value < price) {
            revert Not__EnoughETH();
        }
        if (_tokenIds.current() > limit) {
            revert Done__Minting();
        }

        requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        _tokenIds.increment();
        requestIdToTokenId[requestId] = _tokenIds.current();
        emit RequestRandomNumber(requestId, _tokenIds.current());
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        address nftOwner = requestIdToSender[requestId];
        uint256 tokenId = requestIdToTokenId[requestId];
        tokenIdToRandomNumber[tokenId] = randomNumber;
        _generateTraits(randomNumber, tokenId);
        _safeMint(nftOwner, tokenId);
        emit Minted(tokenId);
    }

    function _generateTraits(uint256 _randomNumber, uint256 _tokenId) internal {
        uint256[] memory randomValues = _expand(_randomNumber, 3);
        // (, int256 ethPrice, , , ) = i_priceFeed.latestRoundData();
        uint256 ethPrice = getPrice();

        if (ethPrice >= threshold) {
            smile[_tokenId] = happySmiles[randomValues[1] % happySmiles.length];
        } else {
            smile[_tokenId] = sadSmiles[randomValues[1] % sadSmiles.length];
        }

        faceShape[_tokenId] = masks[randomValues[1] % 2];
        shapeColor[_tokenId] = colors[randomValues[2] % colors.length];
        faceColor[_tokenId] = colors[randomValues[0] % colors.length];
    }

    function _expand(uint256 _randomNumber, uint256 n)
        private
        pure
        returns (uint256[] memory expandedValues)
    {
        expandedValues = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            expandedValues[i] = uint256(
                keccak256(abi.encode(_randomNumber, i))
            );
        }
        return expandedValues;
    }

    function getPrice() public view returns (uint256) {
        (, int256 ethPrice, , , ) = i_priceFeed.latestRoundData();
        return uint256(ethPrice * 10000000000);
    }

    function tokenURI(uint256 _id)
        public
        view
        override
        returns (string memory finalSVG)
    {
        console.log("token id", _id);
        if (_exists(_id) == false) {
            revert Token__DoesntExists();
        }

        string memory name = string.concat(
            "Random Boring Avatar #",
            _id.toString()
        );
        string
            memory description = "A randomly generated on-chain SVG NFT based on Boring Avatars art";
        string memory image = Base64.encode(bytes(generateSVGofTokenById(_id)));
        finalSVG = string.concat(
            "data:application/json;base64,",
            Base64.encode(
                bytes(
                    string.concat(
                        '{"name":"',
                        name,
                        '", "description":"',
                        description,
                        '",',
                        renderTraits(_id),
                        ', "owner":"',
                        (uint160(ownerOf(_id))).toHexString(20),
                        '", "image":"',
                        "data:image/svg+xml;base64,",
                        image,
                        '"}'
                    )
                )
            )
        );
        return finalSVG;
    }

    function generateSVGofTokenById(uint256 _id)
        internal
        view
        returns (string memory)
    {
        string memory finalSVG = string.concat(
            "<svg viewBox='0 0 36 36' fill='none' role='img' xmlns='http://www.w3.org/2000/svg' width='100' height='100'>",
            svg.mask(
                string.concat(
                    svg.prop("id", _renderFaceShape(_id)), // mask__beam
                    svg.prop("maskUnits", "userSpaceOnUse"),
                    svg.prop("x", "0"),
                    svg.prop("y", "0"),
                    svg.prop("width", "36"),
                    svg.prop("height", "36")
                ),
                svg.rect(
                    string.concat(
                        svg.prop("width", "36"),
                        svg.prop("height", "36"),
                        svg.prop("rx", "72"),
                        svg.prop("fill", "#FFFFFF")
                    ),
                    utils.NULL
                )
            ),
            svg.g(
                svg.prop("mask", "url(#mask__beam)"),
                string.concat(
                    svg.rect(
                        string.concat(
                            svg.prop("width", "36"),
                            svg.prop("height", "36"),
                            svg.prop("fill", _renderShapeColor(_id)) // "#73b06f"
                        ),
                        utils.NULL
                    ),
                    svg.rect(
                        string.concat(
                            svg.prop("x", "0"),
                            svg.prop("y", "0"),
                            svg.prop("width", "36"),
                            svg.prop("height", "36"),
                            svg.prop(
                                "transform",
                                "translate(9 -5) rotate(219 18 18) scale(1)"
                            ),
                            svg.prop("fill", _renderFaceColor(_id)), // "#405059"
                            svg.prop("rx", "6")
                        ),
                        utils.NULL
                    ),
                    svg.g(
                        svg.prop(
                            "transform",
                            "translate(4.5 -4) rotate(9 18 18)"
                        ),
                        string.concat(
                            svg.path(
                                string.concat(
                                    svg.prop("d", _renderSmile(_id)), // "M15 19c2 1 4 1 6 0"
                                    svg.prop("stroke", "#FFFFFF"),
                                    svg.prop("fill", "none"),
                                    svg.prop("stroke-linecap", "round")
                                ),
                                utils.NULL
                            ),
                            svg.rect(
                                string.concat(
                                    svg.prop("x", "10"),
                                    svg.prop("y", "14"),
                                    svg.prop("width", "1.5"),
                                    svg.prop("height", "2"),
                                    svg.prop("rx", "1"),
                                    svg.prop("stroke", "none"),
                                    svg.prop("fill", "#FFFFFF")
                                ),
                                utils.NULL
                            ),
                            svg.rect(
                                string.concat(
                                    svg.prop("x", "24"),
                                    svg.prop("y", "14"),
                                    svg.prop("width", "1.5"),
                                    svg.prop("height", "2"),
                                    svg.prop("rx", "1"),
                                    svg.prop("stroke", "none"),
                                    svg.prop("fill", "#FFFFFF")
                                ),
                                utils.NULL
                            )
                        )
                    )
                )
            ),
            "</svg>"
        );
        return finalSVG;
    }

    function _renderFaceShape(uint256 _id)
        internal
        view
        returns (string memory)
    {
        string memory render = faceShape[_id];
        return render;
    }

    function _renderShapeColor(uint256 _id)
        internal
        view
        returns (string memory)
    {
        string memory render = shapeColor[_id];
        return render;
    }

    function _renderFaceColor(uint256 _id)
        internal
        view
        returns (string memory)
    {
        string memory render = faceColor[_id];
        return render;
    }

    function _renderSmile(uint256 _id) internal view returns (string memory) {
        string memory render = smile[_id];
        return render;
    }

    function renderTraits(uint256 _id) internal view returns (string memory) {
        string memory render = string.concat(
            '"attributes": [{"trait_type": "Face Shape", "value": "',
            faceShape[_id],
            '"}, {"trait_type": "Shape Color", "value": "',
            shapeColor[_id],
            '"},{"trait_type": "Face Color", "value": "',
            faceColor[_id],
            '"} ]'
        );
        return render;
    }
}
