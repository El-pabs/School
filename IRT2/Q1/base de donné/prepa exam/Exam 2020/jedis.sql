-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le :  mer. 08 jan. 2020 à 07:54
-- Version du serveur :  5.7.24
-- Version de PHP :  7.2.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `jedis`
--

-- --------------------------------------------------------

--
-- Structure de la table `citations`
--

DROP TABLE IF EXISTS `citations`;
CREATE TABLE IF NOT EXISTS `citations` (
  `id_citation` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_heros` int(10) UNSIGNED NOT NULL,
  `id_film` int(10) UNSIGNED NOT NULL,
  `citation` text NOT NULL,
  PRIMARY KEY (`id_citation`)
) ENGINE=MyISAM AUTO_INCREMENT=56 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `citations`
--

INSERT INTO `citations` (`id_citation`, `id_heros`, `id_film`, `citation`) VALUES
(1, 14, 1, 'Au secours Obi-Wan Kenobi, vous êtes mon seul espoir.'),
(2, 6, 1, 'Que la force soit avec toi.'),
(3, 1, 2, 'Fais le ou ne le fais pas. Il n\'y a pas d\'essai.'),
(4, 7, 2, 'Je suis ton père.'),
(5, 5, 4, 'Il y en a toujours un pour manger l\'autre.'),
(6, 1, 4, 'La peur est le chemin vers le côté obscur: la peur mène à la colère,  le colère mène à la haine, la haine mène à la souffrance.'),
(7, 4, 5, 'Et si je vous disais que la République est maintenant sous contrôle d\'un seigneur des ténèbres des Sith ?'),
(8, 3, 6, 'Aucune limite à mon pouvoir !'),
(9, 1, 5, 'Personne par la guerre ne devient grand.'),
(10, 14, 2, 'Vous voulez peut-être que je descende pour pousser ?'),
(11, 7, 2, 'Tu sais contrôler ta peur… maintenant libère ta colère. Seule ta haine peut me détruire.'),
(12, 8, 1, 'S’il y a un point central dans cet univers, tu es sur la planète qui en est le plus éloigné…'),
(13, 6, 6, 'C’était toi l’élu !'),
(14, 6, 6, 'La prophétie voulait que tu détruises les Sith pas que tu deviennes comme eux !'),
(15, 6, 1, 'L’œil ne voit que la surface des choses, ne t’y fie pas.'),
(16, 1, 4, 'Toujours par deux, ils vont. Ni plus, ni moins. Un maître et son apprenti. '),
(17, 14, 2, 'Vous avez encore beaucoup de choses à apprendre sur les femmes !'),
(18, 7, 3, 'Il est inutile de résister, mon fils.'),
(19, 14, 2, 'Plutôt embrasser un wookie !'),
(20, 7, 1, 'Tes pouvoirs s’estompent, vieillard.'),
(21, 7, 1, 'Obi-Wan, nous revoilà face à face, quand je vous ai laissé j’étais le disciple, aujourd’hui je suis le maître.'),
(22, 2, 6, 'C\'est dans les nuits les plus obscures que les lumières que nous sommes brillent le plus.'),
(23, 6, 6, 'Seuls les Sith sont aussi absolu !'),
(24, 9, 7, 'Luke Skywalker ? Je croyais que c\'était une légende.'),
(25, 10, 7, 'Montre moi encore, grand père, et je finirai ce que tu as commencé.'),
(26, 12, 6, 'D\'après vos exploits je vous imaginais un peu plus âgé.'),
(27, 13, 8, 'Tu es un enfant avec un masque.'),
(28, 1, 5, 'Bien battu tu t\'es, mon ancien Padawan...'),
(29, 1, 2, 'Toujours en mouvement est l\'avenir.'),
(30, 1, 2, 'Quand 900 ans comme moi tu auras, moins en forme tu seras.'),
(31, 1, 2, 'La taille importe peu. '),
(32, 1, 5, 'Merveilleuse intelligence que celle des enfants.'),
(33, 1, 6, 'En ton nouvel apprenti, ta confiance, un peu trop grande ma paraît, comme l\'est ta foi dans le côté obscur de la Force.'),
(34, 3, 6, 'Exécutez l\'ordre 66.'),
(35, 3, 3, 'Il me tarde de pouvoir achever ta formation. Et, tu m\'appelleras très bientôt maître.'),
(36, 14, 1, 'J\'ai senti votre odeur méphitique dès que je suis montée à bord.'),
(37, 7, 6, 'Si tu n’es pas avec moi, alors tu es contre moi…'),
(38, 9, 7, 'Tu as peur de ne jamais être aussi fort que Dark Vador.'),
(39, 5, 4, 'Concentre-toi sur l’instant présent, ressens, ne pense pas, fie-toi à ton instinct.'),
(40, 8, 2, 'Il y a toujours du bon en lui. Je l\'ai senti.'),
(41, 8, 3, 'Votre trop grande confiance en vous est votre faille.'),
(42, 6, 6, 'Les seigneurs Sith ont toujours été notre spécialité.'),
(43, 8, 3, 'Je suis un Jedi, comme mon père l\'avait été avant moi.'),
(44, 3, 6, 'Une fois de plus, les Sith domineront la Galaxie ! Et là, nous connaîtrons enfin... la paix !'),
(45, 6, 1, 'Tu ne peux pas gagner, si tu me terrasses je deviendrai bien plus puissant que tu ne pourrais jamais l\'imaginer.'),
(46, 3, 5, 'Et mon premier acte concret et fort de ma nouvelle autorité, sera de créer une grande armée de la République, pour contrer la menace grandissante des séparatistes.'),
(47, 6, 6, 'Tu étais l\'élu c\'était toi, la prophétie voulait que tu détruises les Sith pas que tu deviennes comme eux ! Tu devais amener l\'équilibre dans la Force, pas la condamner à la nuit !'),
(48, 7, 3, 'L\'Empereur te montrera la vraie nature de la Force.'),
(49, 6, 4, 'Vous aviez raison, maître. Les négociations n\'ont pas duré longtemps.'),
(50, 7, 6, 'J’ai apporté la paix, la justice, la liberté et la sécurité à mon nouvel empire !'),
(51, 1, 5, 'De débuter vient juste la guerre des clones.'),
(52, 6, 1, 'Ce n\'est pas une lune, c\'est une base sidérale !'),
(53, 14, 1, 'Vous êtes venu dans cette casserole ? Vous êtes plus brave que je ne le pensais.'),
(54, 7, 3, 'Pour une fois, laisse-moi te regarder avec mes propres yeux.'),
(55, 8, 8, 'Demain. A l\'aube. Trois leçons. Je t\'enseignerai la voie des Jedi... et pourquoi il est temps d\'en finir.');

-- --------------------------------------------------------

--
-- Structure de la table `films`
--

DROP TABLE IF EXISTS `films`;
CREATE TABLE IF NOT EXISTS `films` (
  `id_film` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `annee` int(3) UNSIGNED NOT NULL,
  `titre` varchar(128) NOT NULL,
  `trilogie` tinyint(3) UNSIGNED NOT NULL,
  `episode` tinyint(3) UNSIGNED NOT NULL,
  `realisateur` varchar(64) NOT NULL,
  `favori` int(10) UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_film`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `films`
--

INSERT INTO `films` (`id_film`, `annee`, `titre`, `trilogie`, `episode`, `realisateur`, `favori`) VALUES
(1, 1977, 'Un nouvel espoir', 1, 4, 'George Lucas', 2),
(2, 1980, 'L\'Empire contre-attaque', 1, 5, 'Irvin Kershner', 4),
(3, 1983, 'Le Retour du Jedi', 1, 6, 'Richard Marquand', 4),
(4, 1999, 'La Menace fantôme', 2, 1, 'George Lucas', 0),
(5, 2002, 'L\'Attaque des clones', 2, 2, 'George Lucas', 1),
(6, 2005, 'La Revanche des Sith', 2, 3, 'George Lucas', 2),
(7, 2015, 'Le Réveil de la Force', 3, 7, 'J. J. Abrams', 1),
(8, 2017, 'Les Derniers Jedi', 3, 8, 'Rian Johnson', 2),
(9, 2019, 'L\'Ascension de Skywalker', 3, 9, 'J. J. Abrams', 1),
(10, 2016, 'Rogue One : Une histoire de Star Wars', 0, 0, 'Gareth Edwards', 0),
(11, 2018, 'Solo : Une histoire de Star Wars', 0, 0, 'Ron Howard', 0);

-- --------------------------------------------------------

--
-- Structure de la table `heros`
--

DROP TABLE IF EXISTS `heros`;
CREATE TABLE IF NOT EXISTS `heros` (
  `id_heros` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_maitre` int(10) UNSIGNED NOT NULL,
  `cote_obscur` tinyint(1) NOT NULL,
  `nom` varchar(64) NOT NULL,
  `surnom` varchar(128) NOT NULL,
  `secondaire` tinyint(1) NOT NULL DEFAULT '0',
  `sabres` varchar(64) NOT NULL,
  `premiere_apparition` int(10) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Numéro d''épisode',
  PRIMARY KEY (`id_heros`)
) ENGINE=MyISAM AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `heros`
--

INSERT INTO `heros` (`id_heros`, `id_maitre`, `cote_obscur`, `nom`, `surnom`, `secondaire`, `sabres`, `premiere_apparition`) VALUES
(1, 0, 0, 'Yoda', '', 0, 'green', 1),
(2, 0, 0, 'Mace Windu', '', 0, 'pink', 1),
(3, 0, 1, 'Palpatine', 'Dark Sidious', 0, 'red', 1),
(4, 1, 1, 'Dooku', 'Dark Tyranus', 0, 'red', 2),
(5, 4, 0, 'Qui-Gon Jinn', '', 0, 'green', 1),
(6, 5, 0, 'Obi-Wan Kenobi', '', 0, 'blue;green;blue', 1),
(7, 6, 1, 'Anakin Skywalker', 'Dark Vador', 0, 'blue;red', 1),
(8, 1, 0, 'Luke Skywalker', '', 0, 'blue;green', 4),
(9, 8, 0, 'Rey', '', 0, 'blue', 7),
(10, 8, 1, 'Ben Solo', 'Kylo Ren', 0, 'blue;red', 7),
(11, 3, 1, '', 'Dark Maul', 0, 'red;red', 1),
(12, 4, 1, 'Qymaen Jai Sheeiai', 'général Grievous', 0, 'blue;green;blue;green', 3),
(13, 3, 1, 'Snoke', '', 0, '', 7),
(14, 0, 0, 'Leia Organa', 'Princesse Leia', 0, '', 4),
(15, 0, 0, 'Kit Fisto', '', 1, 'green', 2),
(16, 0, 0, 'Agen Kolar', '', 1, 'blue', 2),
(17, 0, 0, 'Saesee Tiin', '', 1, 'green', 2),
(18, 0, 0, 'Plo Koon', '', 1, 'blue', 1),
(19, 0, 0, 'Ki-Adi_mundi', '', 1, 'blue', 1),
(20, 0, 0, 'Barriss Offee', '', 1, 'blue', 2),
(21, 0, 0, 'Even Piell', '', 1, 'blue', 1),
(22, 0, 0, 'Eeth Koth', '', 1, 'green', 1),
(23, 0, 0, 'Coleman Trebor', '', 1, 'green', 2),
(24, 0, 0, 'Shaak Ti', '', 1, 'blue', 2),
(25, 0, 0, 'Aayla Secura', '', 1, 'blue', 2);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
