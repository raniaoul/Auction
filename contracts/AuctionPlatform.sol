// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionPlatform {
    struct Auction {
        address owner;
        string itemDescription;
        address highestBidder;
        uint256 highestBid;
        uint256 endTime;
        bool ended;
        mapping(address => uint256) bids;
    }

    uint256 public auctionCount;
    mapping(uint256 => Auction) public auctions;
    uint256[] public activeAuctionIds; // List of active auction IDs

    event AuctionCreated(uint256 auctionId, address indexed owner, string itemDescription, uint256 endTime);
    event BidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionEnded(uint256 indexed auctionId, address winner, uint256 amount);

    modifier onlyOwner(uint256 _auctionId) {
        require(msg.sender == auctions[_auctionId].owner, "Only the auction owner can perform this action");
        _;
    }

    modifier auctionActive(uint256 _auctionId) {
        require(block.timestamp < auctions[_auctionId].endTime, "Auction has ended");
        require(!auctions[_auctionId].ended, "Auction already ended");
        _;
    }

    function createAuction(string calldata _itemDescription, uint256 _duration) external {
        auctionCount++;
        Auction storage auction = auctions[auctionCount];
        auction.owner = msg.sender;
        auction.itemDescription = _itemDescription;
        auction.endTime = block.timestamp + _duration;
        
        activeAuctionIds.push(auctionCount); // Add auction ID to active list
        emit AuctionCreated(auctionCount, msg.sender, _itemDescription, auction.endTime);
    }

    function placeBid(uint256 _auctionId) external payable auctionActive(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(msg.value > auction.highestBid, "Bid is not high enough");

        // Refund the previous highest bidder
        if (auction.highestBidder != address(0)) {
            auction.bids[auction.highestBidder] += auction.highestBid;
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        
        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    function withdraw(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];
        uint256 amount = auction.bids[msg.sender];
        require(amount > 0, "No funds to withdraw");

        auction.bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

   function endAuction(uint256 _auctionId) external onlyOwner(_auctionId) {
    Auction storage auction = auctions[_auctionId];
    require(!auction.ended, "Auction already ended");

    auction.ended = true;
    emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);

    // Transfer the highest bid to the auction owner
    payable(auction.owner).transfer(auction.highestBid);

    // Remove auction from the list of active auctions
    _removeAuctionFromActiveList(_auctionId);
}
    // Internal function to remove the auction from activeAuctionIds
    function _removeAuctionFromActiveList(uint256 _auctionId) internal {
        for (uint256 i = 0; i < activeAuctionIds.length; i++) {
            if (activeAuctionIds[i] == _auctionId) {
                activeAuctionIds[i] = activeAuctionIds[activeAuctionIds.length - 1];
                activeAuctionIds.pop();
                break;
            }
        }
    }

    // Function to retrieve all active auction IDs
    function getActiveAuctionIds() external view returns (uint256[] memory) {
        return activeAuctionIds;
    }

    // Function to get details of an auction
    function getAuctionDetails(uint256 _auctionId) external view returns (
        address owner,
        string memory itemDescription,
        address highestBidder,
        uint256 highestBid,
        uint256 endTime,
        bool ended
    ) {
        Auction storage auction = auctions[_auctionId];
        return (
            auction.owner,
            auction.itemDescription,
            auction.highestBidder,
            auction.highestBid,
            auction.endTime,
            auction.ended
        );
    }

    // Function to get the highest bid and bidder for a specific auction
    function getHighestBid(uint256 _auctionId) external view returns (address highestBidder, uint256 highestBid) {
        Auction storage auction = auctions[_auctionId];
        return (auction.highestBidder, auction.highestBid);
    }
}
