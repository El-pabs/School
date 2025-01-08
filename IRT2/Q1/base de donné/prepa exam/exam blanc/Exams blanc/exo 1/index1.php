<?php

include_once('_connexionBD.php');


$req_pays = $bd->query('SELECT v.ville AS nom_ville,v.id_ville , p.pays AS nom_pays, p.code AS code_pays, COUNT(r.id_restaurant) AS nbr 
FROM villes v
LEFT JOIN pays p ON v.code_pays = p.code
LEFT JOIN restaurants r ON v.id_ville = r.id_ville
GROUP BY v.ville
ORDER BY nbr DESC, v.ville ASC
LIMIT 10');


$req_liste = $bd->query('SELECT v.ville, v.id_ville FROM villes v
RIGHT JOIN restaurants r ON v.id_ville = r.id_ville
GROUP BY ville
ORDER BY ville ASC');

if (isset($_GET['liste'])) {
    $valeur = $_GET['liste'];
    $req_formulaire = $bd->prepare('SELECT r.nom, r.description FROM restaurants r
    WHERE r.id_ville = :id AND r.ouvert = 1
    ORDER BY r.nom ASC');
    $req_formulaire->bindValue(':id', $valeur);
    $req_formulaire->execute();
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
            color : black;
            text-decoration : none;
        }
    </style>
</head>
<body>
    <h2>Classement</h2>
    <?php
    $i = 1;
    while ($pays = $req_pays->fetch()){
        $compte = $pays['nbr'];
        if ($i < 4){
            echo '<b>';
        }
        echo '<a href="?liste='.$pays['id_ville'].'">'.$i. ' ' .$pays['nom_ville'].' : </b> <img src="flags/'.$pays['code_pays'].'" alt=""> </a> ' .$pays['nom_pays'].' : ';
        while ($compte != 0){
            echo '<img src="icones/restaurant.png" alt="restaurant" width=30>';
            $compte -= 1;
        }
        echo '<br>';
        $i += 1;
    }
    ?>
    <h2>Formulaire</h2>

    <form method="get">
        <select name="liste" >
            <?php while ($liste = $req_liste->fetch()) {
                if (isset($req_formulaire) AND $liste['id_ville'] == $valeur) {
                   echo' <option selected value="'.$liste['id_ville'].'">'.$liste['ville'].'</option>';
                }
            echo '<option value="'.$liste['id_ville'].'">'.$liste['ville'].'</option>';
        }
        ?>
        </select>
        <button type="submit">Envoyer</button>
    </form>

    <?php
    if (isset($req_formulaire)){
        while ($value = $req_formulaire->fetch()) {
            echo '<b> '.$value['nom'].'</b> (' .$value['description']. ')<p>';
        }
    }
?>
</body>
</html>