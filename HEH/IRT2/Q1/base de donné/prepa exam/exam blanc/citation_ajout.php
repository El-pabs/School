<?php
require_once('_connexionBD.php');

$errors = [
    'hero' => '',
    'film' => '',
    'citation' => ''
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $hero_id = $_POST['hero_id'];
    $film_id = $_POST['film_id'];
    $citation = $_POST['citation'];

    // Vérifier que le héros choisi est un héros non secondaire existant en BD
    $hero_exists = $bd->prepare('SELECT COUNT(*) FROM heros WHERE id_heros = ? AND secondaire = 0');
    $hero_exists->execute([$hero_id]);
    if ($hero_exists->fetchColumn() == 0) {
        $errors['hero'] = 'Le héros choisi n\'existe pas ou est un héros secondaire.';
    }

    // Vérifier que le film choisi est un film existant en BD
    $film_exists = $bd->prepare('SELECT COUNT(*) FROM films WHERE id_film = ?');
    $film_exists->execute([$film_id]);
    if ($film_exists->fetchColumn() == 0) {
        $errors['film'] = 'Le film choisi n\'existe pas.';
    }

    // Vérifier que la citation n'est pas vide
    if (empty($citation)) {
        $errors['citation'] = 'La citation ne peut pas être vide.';
    }

    // Si aucune erreur, insérer la citation et rediriger
    if (empty($errors['hero']) && empty($errors['film']) && empty($errors['citation'])) {
        $stmt = $bd->prepare('INSERT INTO citations (id_heros, id_film, citation) VALUES (?, ?, ?)');
        $stmt->execute([$hero_id, $film_id, $citation]);

        header('Location: _index_jedi.php?hero_id=' . $hero_id);
        exit;
    }
}

$req_apparition = $bd->query('SELECT id_heros, nom, surnom FROM heros WHERE secondaire = 0');
$req_film = $bd->query('SELECT id_film, titre FROM films');
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ajouter une citation</title>
    <style>
        .error {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <form action="citation_ajout.php" method="post">
        <p class="<?= !empty($errors['hero']) ? 'error' : '' ?>">Héros</p>
        <select name="hero_id">
            <option value="">--Choisir un héros--</option>
            <?php while ($hero = $req_apparition->fetch()) { ?>
                <option value="<?= $hero['id_heros'] ?>" <?= isset($hero_id) && $hero_id == $hero['id_heros'] ? 'selected' : '' ?>><?= $hero['nom'] ?> <?= !empty($hero['surnom']) ? ' "'.$hero['surnom'].'"' : '' ?></option>
            <?php } ?>
        </select>
        <?php if (!empty($errors['hero'])): ?>
            <p class="error"><?= $errors['hero'] ?></p>
        <?php endif; ?>

        <p class="<?= !empty($errors['film']) ? 'error' : '' ?>">Film</p>
        <select name="film_id">
            <option value="">--Choisir un film--</option>
            <?php while ($film = $req_film->fetch()) { ?>
                <option value="<?= $film['id_film'] ?>" <?= isset($film_id) && $film_id == $film['id_film'] ? 'selected' : '' ?>><?= $film['titre'] ?></option>
            <?php } ?>
        </select>
        <?php if (!empty($errors['film'])): ?>
            <p class="error"><?= $errors['film'] ?></p>
        <?php endif; ?>

        <p class="<?= !empty($errors['citation']) ? 'error' : '' ?>">Citation</p>
        <textarea name="citation" cols="30" rows="10"><?= isset($citation) ? htmlspecialchars($citation) : '' ?></textarea>
        <?php if (!empty($errors['citation'])): ?>
            <p class="error"><?= $errors['citation'] ?></p>
        <?php endif; ?>

        <button type="submit">Ajouter</button>
    </form>
</body>
</html>