const networkConfig = {
  default: {
    name: "hardhat",
    fee: "100000000000000000",
    keyHash:
      "0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4",
  },
  31337: {
    name: "localhost",
    keyHash:
      "0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311",
    linkToken: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
    fee: "100000000000000000", // 0.1 LINK
    threshold: "2400000000000000000000", // 2000000000000000000000
  },
  4: {
    name: "rinkeby",
    linkToken: "0x01BE23585060835E02B77ef475b0Cc51aA1e0709",
    vrfCoordinator: "0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B",
    keyHash:
      "0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311",
    fee: "100000000000000000", // 0.1 LINK
    ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
    threshold: "2600000000000000000000", // 200000000000000000000
  },
  // 42: {
  //   name: 'kovan',
  //   linkToken: '0xa36085F69e2889c224210F603D836748e7dC0088',
  //   vrfCoordinator: '0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9',
  //   keyHash: '0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4',
  //   fee: '100000000000000000', // 0.1 LINK
  // },
  // 80001: {
  //   name: 'mumbai',
  //   linkToken: '0x326C977E6efc84E512bB9C30f76E30c160eD06FB',
  //   vrfCoordinator: '0x8C7382F9D8f56b33781fE506E897a4F1e2d17255',
  //   keyHash: '0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4',
  //   fee: '100000000000000', // 0.0001 LINK
  // }
};

const DECIMALS = "8";
const INITIAL_PRICE = "210000000000";

module.exports = {
  networkConfig,
  DECIMALS,
  INITIAL_PRICE,
};
