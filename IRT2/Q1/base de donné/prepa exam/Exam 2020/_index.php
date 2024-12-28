<?php

require_once('_connexionBD.php');

// Récupérer l'ID du héros cliqué
$hero_id = isset($_GET['hero_id']) ? $_GET['hero_id'] : null;

// Requête pour récupérer les héros
$req_apparition = $bd->query('SELECT id_heros, nom, surnom, cote_obscur AS obscur, sabres FROM heros WHERE secondaire = 0 ORDER BY premiere_apparition');


// Requête pour récupérer les citations du héros cliqué
$req_citations = null;
if ($hero_id) {
    $req_citations = $bd->prepare('SELECT citations.citation, films.titre, films.annee FROM citations JOIN films ON citations.id_film = films.id_film WHERE citations.id_heros = ? ORDER BY films.annee');
    $req_citations->execute([$hero_id]);
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Star Wars</title>
    <link rel="stylesheet" href="style.css">
    <style>

    body {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin: 0;
    height: 100vh;
    justify-content: space-between;
}

.container {
    display: flex;
    justify-content: space-between;
    width: 80%;
    margin-top: 20px;
}

.jedi-container, .sith-container {
    padding-top: 50px;
    width: 45%;
}

.citations, .button-container {
    text-align: center;
    margin-top: 20px;
}

.sabre {
    display: inline-block;
    width: 5px; /* Largeur du rectangle */
    height: 20px; /* Hauteur du rectangle */
    margin-left: 5px; /* Espace entre les rectangles */
    background-color: currentColor; /* Utilise la couleur définie par l'attribut style */
}

.highlight {
    font-weight: bold;
}

button {
    display: block;
    margin: 20px auto;
}

a {    text-decoration: none;
}
    </style>

</head>
<body>
    <div class="container">
        <div class="jedi-container">
            <?php 
            while ($data = $req_apparition->fetch()){
                $highlight = ($data['id_heros'] == $hero_id) ? 'highlight' : '';
                if ($data['obscur'] == 0) {
                    $surnom = !empty($data['surnom']) ? ' "'.$data['surnom'].'"' : '';
                    echo '<p class="jedi '.$highlight.'"><a href="?hero_id='.$data['id_heros'].'" style="text-decoration:none">'.$data['nom'].$surnom.'</a>';
                    if (!empty($data['sabres'])) {
                        $sabres = explode(';', $data['sabres']);
                        foreach ($sabres as $sabre) {
                            echo ' <span class="sabre" style="color:'.$sabre.';"></span>';
                        }
                    }
                    echo '</p>';
                }
            }
            ?>
        </div>
        <div class="sith-container">
            <?php 
            $req_apparition->execute();
            while ($data = $req_apparition->fetch()){
                $highlight = ($data['id_heros'] == $hero_id) ? 'highlight' : '';
                if ($data['obscur'] == 1) {
                    $surnom = !empty($data['surnom']) ? ' "'.$data['surnom'].'"' : '';
                    echo '<p class="sith '.$highlight.'"><a href="?hero_id='.$data['id_heros'].'" style="text-decoration:none">'.$data['nom'].$surnom.'</a>';
                    if (!empty($data['sabres'])) {
                        $sabres = explode(';', $data['sabres']);
                        foreach ($sabres as $sabre) {
                            echo ' <span class="sabre" style="color:'.$sabre.';"></span>';
                        }
                    }
                    echo '</p>';
                }
            }
            ?>
        </div>
    </div>

    <?php if ($hero_id && $req_citations): ?>
        <div class="citations">
            <h2>Citations de <?php 
                $req_apparition->execute();
                while ($data = $req_apparition->fetch()){
                    if ($data['id_heros'] == $hero_id) {
                        $surnom = !empty($data['surnom']) ? ' "'.$data['surnom'].'"' : '';
                        echo $data['nom'].$surnom;
                        break;
                    }
                }
            ?></h2>
            <?php while ($citation = $req_citations->fetch()): ?>
                <p><strong><?php echo $citation['titre']; ?>:</strong> <?php echo $citation['citation']; ?> (<?php echo $citation['annee']; ?>)</p>
            <?php endwhile; ?>
        </div>
    <?php endif; ?>

    <div class="button-container">
    <a href="citation_ajout.php"><button>Citations</button> </a>
    </div>
</body>
</html>