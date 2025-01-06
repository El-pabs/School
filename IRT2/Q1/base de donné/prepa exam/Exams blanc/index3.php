<?php

require_once('_connexionBD.php');

$req_burger = $bd->query('SELECT b.id_burger AS id, b.nom, b.prix, b.stock, GROUP_CONCAT(i.nom) AS ingredients
        FROM burgers b
        RIGHT JOIN liste_ingredients li ON b.id_burger = li.id_burger
        RIGHT JOIN ingredients i ON li.id_ingredient = i.id_ingredient
        GROUP BY b.id_burger
        ORDER BY b.stock DESC
        LIMIT 10');

$req_full_burger = $bd->query('SELECT nom, id_burger FROM burgers');

if (isset($_GET['liste'])){
    $realiser = $_GET['liste'];
    $req_employe = $bd->prepare('SELECT e.nom AS nom, e.prenom AS prenom, SUM(v.nombre * b.prix) AS chiffre_affaires
    FROM burgers b 
    LEFT JOIN ventes v ON b.id_burger = v.id_burger
    LEFT JOIN commandes c ON v.id_commande = c.id_commande
    LEFT JOIN employes e ON c.id_employe = e.id_employe
    WHERE b.id_burger = :id
    GROUP BY e.id_employe
    ORDER BY e.nom ASC
    ');
    $req_employe->bindValue(':id', $realiser);
    $req_employe->execute();

    
    $req_total = $bd->prepare('SELECT SUM(v.nombre * b.prix) AS total_chiffre_affaires
    FROM burgers b 
    LEFT JOIN ventes v ON b.id_burger = v.id_burger
    WHERE b.id_burger = :id
    ');
    $req_total->bindValue(':id', $realiser);
    $req_total->execute();
    $total_chiffre_affaires = $req_total->fetch()['total_chiffre_affaires'];

}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Burger town</title>
    <style>
        a {
            text-decoration: none;
            color : black;
        }
    </style>
</head>
<body>
    <h2>Liste burger</h2>
    <?php 
    while ($burger = $req_burger->fetch()) {
        echo '<a href="?liste='.$burger['id'].'" style="none">';
        if ($burger['id'] < 10) {
            echo '<img src="images/b00'.$burger['id'].'.png" alt="burger" width="100">';
        }
        else {
            echo '<img src="images/b0'.$burger['id'].'.png" alt="burger" width="100">';
        }
        echo '<p>Nom: ' .$burger['nom']. '</p>';
        echo '<p>Prix: ' .$burger['prix']. ' €</p>';
        echo '<p>Stock: ' .$burger['stock']. ' :</p> </a>';
        
        if ($burger['ingredients']) {
            $ingredients = explode(',', $burger['ingredients']);
            foreach ($ingredients as $ingredient) {
                echo '<img src="icones/'.$ingredient.'.png" alt="'.$ingredient.'" width="30">';
            }
            echo '</p>';
        } else {
            echo '<p>Ingrédients: Pas disponible</p>';
        }
    }
    ?>
    <h2>Formulaire</h2>

    <form method="get">
        <select name="liste">
        <?php 
            while ($all = $req_full_burger->fetch()) {
            if (isset($realiser)&& $all['id_burger'] == $realiser){
                echo '<option selected value="'.$all['id_burger'].'">'.$all['nom'].'</option>';}
            echo '<option value="'.$all['id_burger'].' "> '.$all['nom'].' </option>';
            } ?>
        </select>
        <button type="submit">Envoyer</button>
    </form>

    <?php
    while ($employer = $req_employe->fetch()) {
        echo '<p>' .$employer['nom']. ' - ' .$employer['prenom']. ' : ' .$employer['chiffre_affaires']. ' €</p>';
    }
    echo '<h2>Chiffre d\'affaires total pour ce burger</h2>';
        echo '<p>' .$total_chiffre_affaires. ' €</p>';
?>

</body>
</html>