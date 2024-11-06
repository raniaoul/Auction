// src/components/AuctionList.js
import React from 'react';

const AuctionList = ({ auctions, contract, account }) => {
  const placeBid = async (auctionId, amount) => {
    try {
      await contract.methods.placeBid(auctionId).send({
        from: account,
        value: contract.web3.utils.toWei(amount, 'ether')
      });
      alert("Enchère placée avec succès !");
    } catch (error) {
      alert("Erreur lors de l'enchère : " + error.message);
    }
  };

  return (
    <div>
      <h2>Enchères Actives</h2>
      {auctions.map((auction, index) => (
        <div key={index}>
          <h3>{auction.itemDescription}</h3>
          <p>Enchère la plus haute : {contract.web3.utils.fromWei(auction.highestBid, 'ether')} ETH</p>
          <p>Propriétaire : {auction.owner}</p>
          <button onClick={() => placeBid(auction.id, '0.1')}>Placer une enchère de 0.1 ETH</button>
        </div>
      ))}
    </div>
  );
};

export default AuctionList;