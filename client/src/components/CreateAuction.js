// src/components/CreateAuction.js
import React, { useState } from 'react';

const CreateAuction = ({ contract, account }) => {
  const [description, setDescription] = useState('');
  const [duration, setDuration] = useState('');

  const createAuction = async () => {
    if (!contract) {
      alert("Le contrat n'est pas encore chargé. Veuillez réessayer plus tard.");
      return;
    }

    try {
      await contract.methods.createAuction(description, duration).send({ from: account });
      alert("Enchère créée avec succès !");
    } catch (error) {
      alert("Erreur lors de la création de l'enchère : " + error.message);
    }
  };

  return (
    <div>
      <h2>Créer une Nouvelle Enchère</h2>
      <input
        type="text"
        placeholder="Description de l'objet"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />
      <input
        type="number"
        placeholder="Durée en secondes"
        value={duration}
        onChange={(e) => setDuration(e.target.value)}
      />
      <button onClick={createAuction}>Créer l'enchère</button>
    </div>
  );
};

export default CreateAuction;
