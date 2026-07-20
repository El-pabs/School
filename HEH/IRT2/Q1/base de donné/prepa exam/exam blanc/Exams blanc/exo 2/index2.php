<?php

include_once('_connexionBD.PHP');

$req_restaurant = $bd->query('SELECT r.nom, r.description, r.id_restaurant, GROUP_CONCAT(e.nom) AS travailleur, SUM(e.manager) AS manager, v.ville, v.code_pays 
        FROM restaurants r 
        LEFT JOIN employes e ON r.id_restaurant = e.id_restaurant 
        LEFT JOIN villes v ON r.id_ville = v.id_ville 
        WHERE r.ouvert = 1 
        GROUP BY r.id_restaurant 
        ORDER BY r.nom ASC');

$req_formulaire = $bd->query('SELECT r.nom, r.id_restaurant, count(e.nom) AS nbr 
        FROM restaurants r
        RIGHT JOIN employes e ON r.id_restaurant = e.id_restaurant
        WHERE ouvert = 1
        GROUP BY nom
        HAVING nbr > 0
        ORDER BY nom ASC');

if (isset($_GET['employe'])){
    $valeur = $_GET['employe'];
    $req_employe = $bd->prepare('SELECT e.nom, e.prenom, e.manager, COALESCE(SUM(v.nombre * b.prix), 0) AS chiffre_affaires
    FROM employes e
    LEFT JOIN commandes c ON e.id_employe = c.id_employe
    LEFT JOIN ventes v ON c.id_commande = v.id_commande
    LEFT JOIN burgers b ON v.id_burger = b.id_burger
    LEFT JOIN restaurants r ON e.id_restaurant = r.id_restaurant
    WHERE r.id_restaurant = :id AND e.travail_encore = 1
    GROUP BY e.id_employe
    ORDER BY e.nom ASC');
    $req_employe->bindValue(':id', $valeur);
    $req_employe->execute();

    $req_total = $bd->prepare('SELECT r.nom, COALESCE(SUM(v.nombre * b.prix), 0) AS total_chiffre_affaires
    FROM restaurants r
    LEFT JOIN employes e ON r.id_restaurant = e.id_restaurant
    LEFT JOIN commandes c ON e.id_employe = c.id_employe
    LEFT JOIN ventes v ON c.id_commande = v.id_commande
    LEFT JOIN burgers b ON v.id_burger = b.id_burger
    WHERE r.id_restaurant = :id');
    $req_total->bindValue(':id', $valeur);
    $req_total->execute();
    $total_result = $req_total->fetch();
    $total_chiffre_affaires = $total_result['total_chiffre_affaires'];
    $restaurant_nom = $total_result['nom'];
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
        a {
            text-decoration: none;
            color: black;
        }
    </style>
</head>
<body>
    <h2>Restaurants</h2>
    <?php 
    $i = 1;
    while ($restaurant = $req_restaurant->fetch()) {
        echo $i. ':<img src="flags/'.$restaurant['code_pays'].'" alt="">' ;
        if ($i < 4) {
            echo '<b>';
        }
        echo '<a href="?employe='.$restaurant['id_restaurant'].'">'.$restaurant['ville']. ' : '.$restaurant['nom']. '</a>'; 
        if ($i < 4) {
            echo '</b>';
        }
        echo '<br>' .$restaurant['description'].'<p>';

        $travailleurs = explode(',', $restaurant['travailleur']);
        $manager_count = $restaurant['manager'];
        $total_employes = count($travailleurs);
        
        for ($j = 0; $j < $total_employes; $j++) {
            if ($manager_count > 0) {
                echo '<img src="icones/manager.png" alt="" width="30">';
                $manager_count -= 1;
            } else {
                echo '<img src="icones/employe.png" alt="" width="30">';
            }
        }
        echo '<br>';
        $i += 1;
    }
    ?>
    <form method="get">
        <select name="employe">
            <?php 
            while ($resto = $req_formulaire->fetch()){
                $selected = (isset($valeur) && $resto['id_restaurant'] == $valeur) ? 'selected' : '';
                echo '<option value="'.$resto['id_restaurant'].'" '.$selected.'>'.$resto['nom'].'</option>';
            }
            ?>
        </select>
        <button type="submit">Envoyer</button>
    </form>
    
    <?php
    if (isset($req_employe)) {
        while ($travail = $req_employe->fetch()){
            if ($travail['manager'] == 1){
                echo '<p><b>'.$travail['nom'].' - '.$travail['prenom'].'</b> : '.$travail['chiffre_affaires'].' €</p>';
            } else {
                echo '<p>'.$travail['nom'].' - '.$travail['prenom'].' : '.$travail['chiffre_affaires'].' €</p>';
            }
        }
        echo '<h2>Chiffre d\'affaires total pour le restaurant '.$restaurant_nom.'</h2>';
        echo '<p>'.$total_chiffre_affaires.' €</p>';
    }
    ?>

</body>
</html>