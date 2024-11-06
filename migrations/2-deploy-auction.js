const auction = artifacts.require("AuctionPlatform");

module.exports = function (deployer) {
  deployer.deploy(auction);
};
