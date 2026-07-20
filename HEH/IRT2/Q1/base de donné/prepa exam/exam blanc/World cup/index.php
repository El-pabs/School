<?php 

require_once('_connexionBDworld.php');

$req_match = $bd->query('SELECT pays1,pays2,score1,score2,continent1,continent2
FROM(SELECT p1.pays as pays1,p2.pays as pays2,score1,score2,id_match,p1.id_continent as continent1,p2.id_continent as continent2  FROM matchs 
     JOIN equipes p1 ON p1.code = matchs.equipe1
     JOIN equipes p2 ON p2.code = matchs.equipe2
     ORDER BY id_match DESC LIMIT 8) AS test
ORDER BY test.id_match');

$req_stade = $bd->query('SELECT matchs.id_stade, AVG(matchs.spectateurs) as nbr_spectateur, stades.nom as nom, count(*) as nbr 
from matchs 
RIGHT JOIN stades 
ON matchs.id_stade = stades.id_stade 
GROUP BY id_stade 
HAVING nbr > 4 
ORDER BY nbr_spectateur DESC');

$req_continent = $bd->query('SELECT acronyme, continent, id_continent FROM continents ORDER BY continent');

if (isset($_GET['continent'])){
    $id = $_GET['continent'];
    $req_pays = $bd->prepare('SELECT equipes.code, equipes.pays , participations.place 
    from equipes LEFT JOIN continents ON continents.id_continent = equipes.id_continent 
    LEFT join participations ON equipes.code = participations.code 
    where continents.id_continent=:id 
    HAVING place');
    $req_pays->bindValue(':id',$id);
    $req_pays->execute();

}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>index</title>
</head>
<body>

<h2>Les 8 derniers matchs</h2>
    <?php
    while($data = $req_match->fetch()){
        echo '<p>';
        if (isset($id)) if($data['continent1']==$id) echo '<b>';
        echo $data['pays1'];
        if (isset($id))  if($data['continent1']==$id) echo '</b>';
        echo ' - ';
        if (isset($id))  if($data['continent2']==$id) echo '<b>';
        echo $data['pays2'];
        if (isset($id))  if($data['continent2']==$id) echo '</b>';
        echo' : '.$data['score1'].' - '.$data['score2'].'</p>';
    }
    ?>

<h2>Classement stades</h2>
<?php
while($stadium = $req_stade->fetch()){
    echo '<p> <b>' . $stadium['nom']. '</b> : ' .number_format($stadium['nbr_spectateur'],1,'.',''). ' spectateurs moy. ; ' .$stadium['nbr']. ' matchs' ;}
?>

<h2>Choix du continent</h2>
<form method="get">
    <select name="continent">
        <?php while ($continent = $req_continent->fetch()) { 
            if (isset($id)&& $continent['id_continent'] == $id){
                echo '<option selected value="'.$continent['id_continent'].'">'.$continent['acronyme'].' : '.$continent['continent'].'</option>';
            }
            ?>
        <option value="<?php echo $continent['id_continent']; ?>"> <?php echo $continent['acronyme'] . ' : ' . $continent['continent']; ?> </option> 
    <?php } ?>
    </select>
    <p></p>
    <button type= 'submit'>Voir les pays participants</button>
</form>

<?php 
if (isset($id)){
    while($data = $req_pays->fetch()){
        if($data['place'] >= 8){
            echo '<p> <b>'.$data['pays'].'</b>' ;
        }
        else{
            echo '<p>  <b>'.$data['pays'].'</b> : '.$data['place'].'e' ;
        }
    }
    }
?>

</body>
</html>