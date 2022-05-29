const { ethers } = require("hardhat");
const {
  networkConfig,
  DECIMALS,
  INITIAL_PRICE,
} = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  if (chainId == 31337) {

    // Deploy mocks only if current network is localhost

    console.log(
      "---------------------------------------------------------------------"
    );
    console.log("Deploying mocks ...");
    console.log("Deploying MockV3Aggregator contract ...");
    await deploy("MockV3Aggregator", {
      from: deployer,
      log: true,
      args: [DECIMALS, INITIAL_PRICE],
    });
    console.log("MockV3Aggregator contract deployed.");
    const mockV3Aggregator = await ethers.getContract(
      "MockV3Aggregator",
      deployer
    );
    console.log("Deploying LinkToken contract ...");
    await deploy("LinkToken", {
      from: deployer,
      log: true,
    });
    console.log("LinkToken contract deployed.");
    const linkToken = await ethers.getContract("LinkToken", deployer);
    console.log("Deploying VRFCoordinatorMock contract ...");
    await deploy("VRFCoordinatorMock", {
      from: deployer,
      args: [linkToken.address],
      log: true,
    });
    console.log("VRFCoordinatorMock contract deployed.");
    const vrfCoordinatorMock = await ethers.getContract(
      "VRFCoordinatorMock",
      deployer
    );

    // deploy NFT contract
    const args = [
      vrfCoordinatorMock.address,
      linkToken.address,
      mockV3Aggregator.address,
      networkConfig[chainId].keyHash,
      networkConfig[chainId].fee,
    ];
    console.log(
      "-------------------------------------------------------------------"
    );
    console.log(
      "Deploying DynamicRSVGNFT contract in local hardhat network ..."
    );
    await deploy("DynamicRSVGNFT", { from: deployer, log: true, args });
    const nftContract = await ethers.getContract("DynamicRSVGNFT", deployer);
    console.log(`NFT Contract deployed at ${nftContract.address}`);

    const LINK_TOKEN_AMOUNT = ethers.utils.parseEther("10");
    await linkToken.transfer(nftContract.address, LINK_TOKEN_AMOUNT);

    const createTx = await nftContract.create({
      gasLimit: 300000,
      value: "1000000000000000",
    });
    const txReceipt = await createTx.wait(1);
    const requestId = txReceipt.logs[3].topics[1];
    console.log("requestId", requestId);
    const tokenId = txReceipt.logs[3].topics[2];
    console.log("tokenId", tokenId);
    const randomTx = await vrfCoordinatorMock.callBackWithRandomness(
      requestId,
      22378,
      nftContract.address,
      { gasLimit: 400000 }
    );
    await randomTx.wait(2);
    console.log(
      `You can view the tokenURI here: ${await nftContract.tokenURI(tokenId)}`
    );
  } else {
    const args = [
      networkConfig[chainId].vrfCoordinator,
      networkConfig[chainId].linkToken,
      networkConfig[chainId].ethUsdPriceFeed,
      networkConfig[chainId].keyHash,
      networkConfig[chainId].fee,
    ];

    console.log(
      "-------------------------------------------------------------------"
    );
    console.log("Deploying DynamicRSVGNFT contract ...");
    await deploy("DynamicRSVGNFT", { from: deployer, log: true, args });
    const nftContract = await ethers.getContract("DynamicRSVGNFT", deployer);
    console.log(`NFT Contract deployed at ${nftContract.address}`);
    const networkName = networkConfig[chainId].name;
    console.log(
      `Verify with:\n yarn hardhat verify --network ${networkName} ${
        nftContract.address
      } ${args.toString().replace(/,/g, " ")}`
    );
    // const createTx = await nftContract.create({
    //   gasLimit: 5000000,
    //   value: "1000000000000000",
    // });
    // const txReceipt = await createTx.wait(1);
    // const requestId = txReceipt.logs[3].topics[1];
    // console.log("requestId", requestId);
    // const tokenId = txReceipt.logs[3].topics[2];
    // console.log("tokenId", tokenId);
  }
};
module.exports.tags = ["all", "mocks", "drsvg", "mint"];
