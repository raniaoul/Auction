// src/App.js
import React, { useEffect, useState } from 'react';
import getWeb3 from './Utils/getWeb3';
import configuration from './build/contracts/AuctionPlatform.json'
import AuctionPlatformABI from './build/contracts/AuctionPlatform.json'; 
import AuctionList from './components/AuctionList';
import CreateAuction from './components/CreateAuction';

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [contract, setContract] = useState(null);
  const [account, setAccount] = useState(null);
  const [auctions, setAuctions] = useState([]);

  useEffect(() => {
    const init = async () => {
      try {
        const web3 = await getWeb3();
        setWeb3(web3);

        const accounts = await web3.eth.getAccounts();
        setAccount(accounts[0]);

        const contractAddress = configuration.networks['5777'].address; // Remplacez par l'adresse de votre contrat
        const contract = new web3.eth.Contract(AuctionPlatformABI, contractAddress);
        setContract(contract);

        loadActiveAuctions(contract);
      } catch (error) {
        console.error("Erreur de connexion :", error);
      }
    };
    init();
  }, []);

  const loadActiveAuctions = async (contract) => {
    const auctionIds = await contract.methods.getActiveAuctionIds().call();
    const auctionDetails = await Promise.all(
      auctionIds.map(id => contract.methods.getAuctionDetails(id).call())
    );
    setAuctions(auctionDetails);
  };

  return (
    <div>
      <h1>Plateforme d'Enchères Décentralisée</h1>
      <p>Connecté en tant que : {account}</p>
      <CreateAuction contract={contract} account={account} />
      <AuctionList auctions={auctions} contract={contract} account={account} />
    </div>
  );
};

export default App;