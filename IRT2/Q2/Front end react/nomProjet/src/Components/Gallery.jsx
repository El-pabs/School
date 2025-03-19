import axios from 'axios' // Importation de la bibliothèque axios pour les requêtes HTTP
import Photo from './Photo' // Importation du composant Photo
import { useEffect, useState } from 'react' // Importation des hooks useEffect et useState de React

export default function Gallery() {
    // Déclaration des états locaux
    const [data, setData] = useState([]) // État pour stocker les données des images
    const [filteredImg, setFilteredImg] = useState([]) // État pour stocker les images filtrées
    const [searchTerm, setSearchTerm] = useState('') // État pour stocker le terme de recherche
    const [showId, setShowId] = useState(false) // État pour contrôler l'affichage des IDs
    const [loading, setLoading] = useState(true) // État pour contrôler l'affichage du loader

    // useEffect pour effectuer une requête HTTP lors du montage du composant
    useEffect(() => {
        axios('https://picsum.photos/v2/list?page=2')
            .then(response => response.data) // Extraction des données de la réponse
            .then(data => setData(data)) // Mise à jour de l'état data avec les données reçues
            .then(() => setLoading(false)) // Désactivation du loader une fois les données chargées
    }, []) // Le tableau vide signifie que cet effet ne s'exécute qu'une seule fois

    // Fonction pour gérer les changements dans le champ de recherche
    const handleInputChange = ({ target: { value } }) => {
        // Filtrage des images en fonction de l'auteur
        const filteredImg = data.filter(({ author }) =>
            author.toLowerCase().includes(value.toLowerCase())
        )
        setSearchTerm(value) // Mise à jour de l'état searchTerm avec la valeur du champ de recherche
        setFilteredImg(filteredImg) // Mise à jour de l'état filteredImg avec les images filtrées
    }

    return (
        <>
            <h1>Galerie</h1>
            <div className="search">
                {/* Champ de recherche pour filtrer les images par auteur */}
                <input
                    type="text"
                    value={searchTerm}
                    onChange={handleInputChange}
                    placeholder="Rechercher"
                />
                <div className="show-id">
                    {/* Checkbox pour afficher ou masquer les IDs des images */}
                    <input
                        type="checkbox"
                        onClick={() => setShowId(!showId)}
                    />{' '}
                    Montrer les IDs
                </div>
            </div>
            {/* Loader qui s'affiche pendant le chargement des données */}
            <div className='loader' style={{ display: loading ? 'block' : 'none', margin: 'auto' }}></div>
            <div className="gallery">
                {/* Affichage des images filtrées */}
                {filteredImg.map(item => (
                    <Photo
                        key={item.id}
                        id={item.id}
                        url={item.download_url}
                        size={{ width: '300px', height: '300px' }}
                        author={item.author}
                        showId={showId}
                    />
                ))}
            </div>
        </>
        )
        }