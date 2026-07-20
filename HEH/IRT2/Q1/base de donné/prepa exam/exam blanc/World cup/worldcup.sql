-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : mer. 14 déc. 2022 à 07:56
-- Version du serveur : 5.7.33
-- Version de PHP : 7.4.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `worldcup2018`
--

-- --------------------------------------------------------

--
-- Structure de la table `buts`
--

CREATE TABLE `buts` (
  `id_but` int(10) UNSIGNED NOT NULL,
  `id_match` int(10) UNSIGNED NOT NULL,
  `equipe` varchar(3) NOT NULL,
  `id_joueur` int(10) UNSIGNED DEFAULT NULL,
  `id_joueur_assist` int(10) UNSIGNED DEFAULT NULL,
  `contre_son_camp` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Marque contre son camp',
  `penalty` tinyint(1) NOT NULL DEFAULT '0',
  `minute` tinyint(3) UNSIGNED NOT NULL COMMENT 'Minute de jeu',
  `minute_add` tinyint(3) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `buts`
--

INSERT INTO `buts` (`id_but`, `id_match`, `equipe`, `id_joueur`, `id_joueur_assist`, `contre_son_camp`, `penalty`, `minute`, `minute_add`) VALUES
(1, 1, 'RUS', 1, 2, 0, 0, 12, NULL),
(2, 1, 'RUS', 3, 4, 0, 0, 43, NULL),
(3, 1, 'RUS', 5, 2, 0, 0, 71, NULL),
(4, 1, 'RUS', 3, 5, 0, 0, 90, 1),
(5, 1, 'RUS', 2, NULL, 0, 0, 90, 4),
(6, 2, 'URU', 6, 7, 0, 0, 89, NULL),
(7, 3, 'RUS', 8, NULL, 1, 0, 47, NULL),
(8, 3, 'RUS', 3, 9, 0, 0, 59, NULL),
(9, 3, 'RUS', 5, 10, 0, 0, 62, NULL),
(10, 3, 'EGY', 11, NULL, 0, 1, 73, NULL),
(11, 4, 'URU', 12, 7, 0, 0, 23, NULL),
(12, 5, 'URU', 12, NULL, 0, 0, 10, NULL),
(13, 5, 'URU', 3, NULL, 1, 0, 23, NULL),
(14, 5, 'URU', 13, NULL, 0, 0, 90, NULL),
(15, 6, 'EGY', 11, 14, 0, 0, 22, NULL),
(16, 6, 'KSA', 15, NULL, 0, 1, 45, 6),
(17, 6, 'KSA', 16, 17, 0, 0, 90, 5),
(18, 7, 'IRN', 18, NULL, 1, 0, 90, 5),
(19, 8, 'POR', 19, NULL, 0, 1, 4, NULL),
(20, 8, 'ESP', 21, NULL, 0, 0, 24, NULL),
(21, 8, 'POR', 19, 20, 0, 0, 44, NULL),
(22, 8, 'ESP', 21, 22, 0, 0, 55, NULL),
(23, 8, 'ESP', 23, NULL, 0, 0, 58, NULL),
(24, 8, 'POR', 19, NULL, 0, 0, 88, NULL),
(25, 9, 'POR', 19, 24, 0, 0, 4, NULL),
(26, 10, 'ESP', 21, NULL, 0, 0, 54, NULL),
(27, 11, 'POR', 25, 26, 0, 0, 45, NULL),
(28, 11, 'IRN', 27, NULL, 0, 1, 90, 3),
(29, 12, 'MAR', 28, NULL, 0, 0, 14, NULL),
(30, 12, 'ESP', 29, 30, 0, 0, 18, NULL),
(31, 12, 'MAR', 31, 32, 0, 0, 81, NULL),
(32, 12, 'ESP', 33, 34, 0, 0, 90, 1),
(33, 13, 'FRA', 35, NULL, 0, 1, 58, NULL),
(34, 13, 'AUS', 37, NULL, 0, 1, 62, NULL),
(35, 13, 'FRA', 36, NULL, 1, 0, 81, NULL),
(36, 14, 'DEN', 38, 39, 0, 0, 59, NULL),
(37, 15, 'DEN', 40, 39, 0, 0, 7, NULL),
(38, 15, 'AUS', 37, NULL, 0, 1, 38, NULL),
(39, 16, 'FRA', 41, NULL, 0, 0, 34, NULL),
(40, 18, 'PER', 43, 42, 0, 0, 18, NULL),
(41, 18, 'PER', 42, NULL, 0, 0, 50, NULL),
(42, 19, 'ARG', 44, 45, 0, 0, 19, NULL),
(43, 19, 'ISL', 46, NULL, 0, 0, 23, NULL),
(44, 20, 'CRO', 47, NULL, 1, 0, 32, NULL),
(45, 20, 'CRO', 48, NULL, 0, 1, 72, NULL),
(46, 21, 'CRO', 49, NULL, 0, 0, 53, NULL),
(47, 21, 'CRO', 48, 50, 0, 0, 80, NULL),
(48, 21, 'CRO', 51, 52, 0, 0, 90, 1),
(49, 22, 'NGA', 53, 54, 0, 0, 49, NULL),
(50, 22, 'NGA', 53, 55, 0, 0, 75, NULL),
(51, 23, 'ARG', 56, 57, 0, 0, 14, NULL),
(52, 23, 'NGA', 54, NULL, 0, 1, 51, NULL),
(53, 23, 'ARG', 45, 58, 0, 0, 86, NULL),
(54, 24, 'CRO', 60, 61, 0, 0, 53, NULL),
(55, 24, 'CRO', 62, 60, 0, 0, 90, NULL),
(56, 24, 'ISL', 59, NULL, 0, 1, 76, NULL),
(57, 25, 'SRB', 63, NULL, 0, 0, 56, NULL),
(58, 26, 'BRA', 64, NULL, 0, 0, 20, NULL),
(59, 26, 'SUI', 65, 66, 0, 0, 50, NULL),
(60, 27, 'BRA', 64, 67, 0, 0, 90, 1),
(61, 27, 'BRA', 68, 69, 0, 0, 90, 7),
(62, 28, 'SRB', 71, 70, 0, 0, 5, NULL),
(63, 28, 'SUI', 74, NULL, 0, 0, 52, NULL),
(64, 28, 'SUI', 66, 75, 0, 0, 90, NULL),
(65, 29, 'BRA', 72, 64, 0, 0, 36, NULL),
(66, 29, 'BRA', 73, 68, 0, 0, 68, NULL),
(67, 30, 'SUI', 76, 77, 0, 0, 31, NULL),
(68, 30, 'SUI', 78, 79, 0, 0, 88, NULL),
(69, 30, 'CRC', 80, 81, 0, 0, 56, NULL),
(70, 30, 'CRC', 82, NULL, 1, 0, 90, 3),
(71, 31, 'MEX', 83, 84, 0, 0, 35, NULL),
(72, 32, 'SWE', 85, NULL, 0, 1, 65, NULL),
(73, 33, 'MEX', 86, NULL, 0, 1, 26, NULL),
(74, 33, 'MEX', 84, 83, 0, 0, 66, NULL),
(75, 33, 'KOR', 87, 88, 0, 0, 90, 3),
(76, 34, 'SWE', 89, NULL, 0, 0, 32, NULL),
(77, 34, 'GER', 90, 91, 0, 0, 48, NULL),
(78, 34, 'GER', 92, 90, 0, 0, 90, 5),
(79, 35, 'KOR', 93, NULL, 0, 0, 90, 4),
(80, 35, 'KOR', 87, 94, 0, 0, 90, 6),
(81, 36, 'SWE', 95, NULL, 0, 0, 50, NULL),
(82, 36, 'SWE', 85, NULL, 0, 1, 62, NULL),
(83, 36, 'SWE', 97, NULL, 1, 0, 74, NULL),
(84, 37, 'BEL', 98, NULL, 0, 0, 47, NULL),
(85, 37, 'BEL', 99, 100, 0, 0, 69, NULL),
(86, 37, 'BEL', 99, 101, 0, 0, 75, NULL),
(87, 38, 'ENG', 102, NULL, 0, 0, 11, NULL),
(88, 38, 'ENG', 102, 103, 0, 0, 90, 1),
(89, 38, 'TUN', 104, NULL, 0, 1, 35, NULL),
(90, 39, 'BEL', 101, NULL, 0, 1, 6, NULL),
(91, 39, 'BEL', 99, 98, 0, 0, 16, NULL),
(92, 39, 'TUN', 107, 106, 0, 0, 18, NULL),
(93, 39, 'BEL', 99, 108, 0, 0, 45, 3),
(94, 39, 'BEL', 101, 109, 0, 0, 51, NULL),
(95, 39, 'BEL', 110, 111, 0, 0, 90, NULL),
(96, 39, 'TUN', 106, 105, 0, 0, 90, 3),
(97, 40, 'ENG', 113, 114, 0, 0, 8, NULL),
(98, 40, 'ENG', 102, NULL, 0, 1, 22, NULL),
(99, 40, 'ENG', 115, 116, 0, 0, 36, NULL),
(100, 40, 'ENG', 113, NULL, 0, 0, 40, NULL),
(101, 40, 'ENG', 102, NULL, 0, 1, 45, 1),
(102, 40, 'ENG', 102, NULL, 0, 0, 62, NULL),
(103, 40, 'PAN', 118, 117, 0, 0, 78, NULL),
(104, 41, 'BEL', 112, 111, 0, 0, 51, NULL),
(105, 42, 'PAN', 119, NULL, 1, 0, 33, NULL),
(106, 42, 'TUN', 120, 106, 0, 0, 51, NULL),
(107, 42, 'TUN', 106, 121, 0, 0, 66, NULL),
(108, 43, 'JPN', 123, NULL, 0, 1, 6, NULL),
(109, 43, 'COL', 122, NULL, 0, 0, 39, NULL),
(110, 43, 'JPN', 124, 125, 0, 0, 39, NULL),
(111, 44, 'SEN', 126, NULL, 1, 0, 37, NULL),
(112, 44, 'SEN', 129, NULL, 1, 0, 60, NULL),
(113, 44, 'POL', 128, 127, 0, 0, 86, NULL),
(114, 45, 'SEN', 132, NULL, 0, 0, 11, NULL),
(115, 45, 'JPN', 130, 131, 0, 0, 34, NULL),
(116, 45, 'SEN', 133, 129, 0, 0, 71, NULL),
(117, 45, 'JPN', 125, 130, 0, 0, 78, NULL),
(118, 46, 'COL', 135, 134, 0, 0, 40, NULL),
(119, 46, 'COL', 136, 122, 0, 0, 70, NULL),
(120, 46, 'COL', 137, 134, 0, 0, 75, NULL),
(121, 47, 'POL', 138, 139, 0, 0, 59, NULL),
(122, 48, 'COL', 135, 122, 0, 0, 74, NULL),
(123, 49, 'URU', 13, 12, 0, 0, 7, NULL),
(124, 49, 'POR', 144, 143, 0, 0, 55, NULL),
(125, 49, 'URU', 13, 142, 0, 0, 62, NULL),
(126, 50, 'FRA', 35, NULL, 0, 1, 13, NULL),
(127, 50, 'ARG', 148, 57, 0, 0, 41, NULL),
(128, 50, 'ARG', 58, 56, 0, 0, 48, NULL),
(129, 50, 'FRA', 145, 146, 0, 0, 57, NULL),
(130, 50, 'FRA', 41, NULL, 0, 0, 64, NULL),
(131, 50, 'FRA', 41, 147, 0, 0, 68, NULL),
(132, 50, 'ARG', 44, 56, 0, 0, 90, 3),
(133, 51, 'ESP', 3, NULL, 1, 0, 12, NULL),
(134, 51, 'RUS', 5, NULL, 0, 1, 41, NULL),
(135, 52, 'DEN', 151, 152, 0, 0, 1, NULL),
(136, 52, 'CRO', 153, NULL, 0, 0, 4, NULL),
(137, 53, 'BRA', 68, 154, 0, 0, 51, NULL),
(138, 53, 'BRA', 155, NULL, 0, 0, 88, NULL),
(139, 54, 'JPN', 159, 160, 0, 0, 48, NULL),
(140, 54, 'JPN', 130, 123, 0, 0, 52, NULL),
(141, 54, 'BEL', 156, NULL, 0, 0, 69, NULL),
(142, 54, 'BEL', 157, 101, 0, 0, 74, NULL),
(143, 54, 'BEL', 158, 108, 0, 0, 90, 4),
(144, 55, 'SWE', 161, 89, 0, 0, 66, NULL),
(145, 56, 'ENG', 102, NULL, 0, 1, 57, NULL),
(146, 56, 'COL', 135, 137, 0, 0, 90, 3),
(147, 57, 'FRA', 162, 35, 0, 0, 40, NULL),
(148, 57, 'FRA', 35, 163, 0, 0, 61, NULL),
(149, 58, 'BEL', 164, NULL, 1, 0, 13, NULL),
(150, 58, 'BEL', 100, 99, 0, 0, 31, NULL),
(151, 58, 'BRA', 165, 64, 0, 0, 76, NULL),
(152, 59, 'ENG', 103, 166, 0, 0, 30, NULL),
(153, 59, 'ENG', 167, 115, 0, 0, 59, NULL),
(154, 60, 'RUS', 3, 5, 0, 0, 31, NULL),
(155, 60, 'CRO', 171, 153, 0, 0, 39, NULL),
(156, 60, 'RUS', 9, 169, 0, 0, 115, NULL),
(157, 60, 'CRO', 172, 48, 0, 0, 101, NULL),
(158, 61, 'FRA', 184, 35, 0, 0, 51, NULL),
(159, 62, 'ENG', 114, NULL, 0, 0, 5, NULL),
(160, 62, 'CRO', 62, 185, 0, 0, 68, NULL),
(161, 62, 'CRO', 153, 62, 0, 0, 109, NULL),
(162, 63, 'BEL', 108, 158, 0, 0, 4, NULL),
(163, 63, 'BEL', 101, 100, 0, 0, 82, NULL),
(164, 64, 'FRA', 153, NULL, 1, 0, 18, NULL),
(165, 64, 'CRO', 62, 172, 0, 0, 28, NULL),
(166, 64, 'FRA', 35, NULL, 0, 1, 38, NULL),
(167, 64, 'FRA', 186, NULL, 0, 0, 59, NULL),
(168, 64, 'FRA', 41, 84, 0, 0, 65, NULL),
(169, 64, 'CRO', 153, NULL, 0, 0, 69, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `championnats`
--

CREATE TABLE `championnats` (
  `annee` smallint(10) UNSIGNED NOT NULL,
  `nom` varchar(128) NOT NULL,
  `lieu` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `championnats`
--

INSERT INTO `championnats` (`annee`, `nom`, `lieu`) VALUES
(2018, 'Coupe du monde', 'Russie');

-- --------------------------------------------------------

--
-- Structure de la table `continents`
--

CREATE TABLE `continents` (
  `id_continent` tinyint(3) UNSIGNED NOT NULL,
  `continent` varchar(64) NOT NULL,
  `acronyme` varchar(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `continents`
--

INSERT INTO `continents` (`id_continent`, `continent`, `acronyme`) VALUES
(1, 'Afrique', 'CAF'),
(2, 'Amérique du Nord, Centrale et Caraïbes', 'CONCACAF'),
(3, 'Amérique du sud', 'CONMEBOL'),
(4, 'Europe', 'UEFA'),
(5, 'Asie', 'AFC');

-- --------------------------------------------------------

--
-- Structure de la table `equipes`
--

CREATE TABLE `equipes` (
  `code` varchar(3) NOT NULL,
  `pays` varchar(64) NOT NULL,
  `federation` varchar(128) DEFAULT NULL,
  `id_continent` tinyint(3) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `equipes`
--

INSERT INTO `equipes` (`code`, `pays`, `federation`, `id_continent`) VALUES
('AFG', 'Afghanistan', 'Fédération d\'Afghanistan de football', 5),
('AIA', 'Anguilla', 'Fédération d\'Anguilla de football', NULL),
('ALB', 'Albanie', 'Fédération albanaise de football', 4),
('ALG', 'Algérie', 'Fédération algérienne de football', 1),
('AND', 'Andorre', 'Fédération d\'Andorre de football', 4),
('ANG', 'Angola', 'Fédération d\'Angola de football', 1),
('ARG', 'Argentine', 'Association du football argentin', 3),
('ARM', 'Arménie', 'Fédération de football d\'Arménie', NULL),
('ARU', 'Aruba', 'Fédération d\'Aruba de football', NULL),
('ASA', 'Samoa américaines', 'Fédération des Samoa américaines de football', NULL),
('AUS', 'Australie', 'Fédération d\'Australie de football', 5),
('AUT', 'Autriche', 'Fédération autrichienne de football', 4),
('AZE', 'Azerbaïdjan', 'Fédération d\'Azerbaïdjan de football', 5),
('BAH', 'Bahamas', 'Fédération des Bahamas de football', NULL),
('BAN', 'Bangladesh', 'Fédération du Bangladesh de football', NULL),
('BDI', 'Burundi', 'Fédération de football du Burundi', 1),
('BEL', 'Belgique', 'Union royale belge des sociétés de football association', 4),
('BEN', 'Bénin', 'Fédération béninoise de football', NULL),
('BER', 'Bermudes', 'Fédération des Bermudes de football', NULL),
('BFA', 'Burkina Faso', 'Fédération burkinabé de football', 1),
('BHU', 'Bhoutan', 'Fédération du Bhoutan de football', NULL),
('BIH', 'Bosnie-Herzégovine', 'Fédération de football de Bosnie-Herzégovine', NULL),
('BLR', 'Biélorussie', 'Fédération biélorusse de football', 4),
('BLZ', 'Belize', 'Fédération du Belize de football', 2),
('BOL', 'Bolivie', 'Fédération bolivienne de football', 3),
('BOT', 'Botswana', 'Fédération du Botswana de football', NULL),
('BRA', 'Brésil', 'Confédération brésilienne de football', 3),
('BRU', 'Brunei', 'Fédération de Brunei de football', NULL),
('BUL', 'Bulgarie', 'Fédération de Bulgarie de football', 4),
('CAM', 'Cambodge', 'Fédération du Cambodge de football', 5),
('CAN', 'Canada', 'Association canadienne de soccer', 2),
('CAY', 'Îles Caïmans', 'Fédération des Îles Caïmans de football', NULL),
('CGO', 'Congo', 'Fédération congolaise de football', 1),
('CHA', 'Tchad', 'Fédération tchadienne de football', NULL),
('CHI', 'Chili', 'Fédération du Chili de football', 3),
('CHN', 'Chine', 'Fédération de Chine de football', 5),
('CIV', 'Côte d\'Ivoire', 'Fédération ivoirienne de football', NULL),
('CMR', 'Cameroun', 'Fédération camerounaise de football', 1),
('COD', 'République Démocratique du Congo', 'Fédération congolaise de football association', 1),
('COK', 'Îles Cook', 'Fédération des Îles Cook de football', NULL),
('COL', 'Colombie', 'Fédération colombienne de football', 3),
('COM', 'Comores', 'Fédération comorienne de football', NULL),
('CPV', 'Cap-Vert', 'Fédération du Cap-Vert de football', NULL),
('CRC', 'Costa Rica', 'Fédération du Costa Rica de football', 2),
('CRO', 'Croatie', 'Fédération croate de football', 4),
('CUB', 'Cuba', 'Fédération de Cuba de football', 2),
('CUR', 'Curaçao', 'Fédération de Curaçao de football', NULL),
('CYP', 'Chypre', 'Fédération chypriote de football', 4),
('CZE', 'République tchèque', 'Fédération de République tchèque de football', 4),
('DEN', 'Danemark', 'Fédération danoise de football', 4),
('DJI', 'Djibouti', 'Fédération djiboutienne de football', NULL),
('DMA', 'Dominique', 'Fédération de Dominique de football', NULL),
('DOM', 'République dominicaine', 'Fédération de République dominicaine de football', NULL),
('ECU', 'Équateur', 'Fédération équatorienne de football', 3),
('EGY', 'Égypte', 'Fédération égyptienne de football', 1),
('ENG', 'Angleterre', 'Fédération anglaise de football', 4),
('ERI', 'Érythrée', 'Fédération d\'Érythrée de football', NULL),
('ESP', 'Espagne', 'Fédération royale espagnole de football', 4),
('EST', 'Estonie', 'Fédération estonienne de football', 4),
('ESW', 'Eswatini', 'Fédération d\'Eswatini de football', NULL),
('ETH', 'Éthiopie', 'Fédération éthiopienne de football', 1),
('FIJ', 'Fidji', 'Fédération des Fidji de football', 5),
('FIN', 'Finlande', 'Association finlandaise de football', 4),
('FRA', 'France', 'Fédération française de football', 4),
('FRO', 'Îles Féroé', 'Fédération des îles Féroé de football', 4),
('GAB', 'Gabon', 'Fédération gabonaise de football', 1),
('GAM', 'Gambie', 'Fédération de Gambie de football', 1),
('GEO', 'Géorgie', 'Fédération géorgienne de football', NULL),
('GER', 'Allemagne', 'Fédération allemande de football', 4),
('GHA', 'Ghana', 'Fédération du Ghana de football', 1),
('GIB', 'Gibraltar', 'Fédération de football de Gibraltar', 4),
('GRE', 'Grèce', 'Fédération hellénique de football', 4),
('GRN', 'Grenade', 'Fédération grenadienne de football', NULL),
('GUA', 'Guam', 'Fédération de Guam de football', NULL),
('GUI', 'Guinée', 'Fédération guinéenne de football', NULL),
('GUM', 'Guatemala', 'Fédération du Guatemala de football', 2),
('GUY', 'Guyana', 'Fédération du Guyana de football', NULL),
('HAI', 'Haïti', 'Fédération haïtienne de football', 2),
('HKG', 'Hong Kong', 'Fédération de Hong Kong de football', 5),
('HON', 'Honduras', 'Fédération du Honduras de football', 2),
('HUN', 'Hongrie', 'Fédération hongroise de football', 4),
('IDN', 'Indonésie', 'Fédération d\'Indonésie de football', 5),
('IND', 'Inde', 'Fédération d\'Inde de football', 5),
('IRL', 'Irlande', 'Fédération d\'Irlande de football', 4),
('IRN', 'Iran', 'Fédération d\'Iran de football', 5),
('IRQ', 'Irak', 'Fédération d\'Irak de football', 5),
('ISL', 'Islande', 'Fédération d\'Islande de football', 4),
('ISR', 'Israël', 'Fédération d\'Israël de football', 5),
('ITA', 'Italie', 'Fédération italienne de football', 4),
('JAM', 'Jamaïque', 'Fédération de Jamaïque de football', 2),
('JOR', 'Jordanie', 'Fédération de Jordanie de football', 5),
('JPN', 'Japon', 'Fédération japonaise de football', 5),
('KAZ', 'Kazakhstan', 'Fédération du Kazakhstan de football', 5),
('KEN', 'Kenya', 'Fédération du Kenya de football', 1),
('KGZ', 'Kirghizistan', 'Fédération du Kirghizistan de football', 5),
('KOR', 'Corée du Sud', 'Fédération de Corée du Sud de football', 5),
('KSA', 'Arabie saoudite', 'Fédération d\'Arabie saoudite de football', 5),
('KUW', 'Koweït', 'Fédération du Koweït de football', 5),
('KVX', 'Kosovo', 'Fédération du Kosovo de football', 4),
('LAO', 'Laos', 'Fédération du Laos de football', 5),
('LBN', 'Liban', 'Fédération du Liban de football', 5),
('LBR', 'Liberia', 'Fédération du Liberia de football', NULL),
('LBY', 'Libye', 'Fédération de Libye de football', NULL),
('LCA', 'Sainte-Lucie', 'Fédération de Sainte-Lucie de football', NULL),
('LES', 'Lesotho', 'Fédération du Lesotho de football', NULL),
('LIE', 'Liechtenstein', 'Fédération du Liechtenstein de football', 4),
('LTU', 'Lituanie', 'Fédération de Lituanie de football', 4),
('LUX', 'Luxembourg', 'Fédération luxembourgeoise de football', 4),
('LVA', 'Lettonie', 'Fédération de Lettonie de football', 4),
('MAC', 'Macao', 'Fédération de Macao de football', NULL),
('MAD', 'Madagascar', 'Fédération malgache de football', 1),
('MAR', 'Maroc', 'Fédération royale marocaine de football', 1),
('MAS', 'Malaisie', 'Fédération de Malaisie de football', 5),
('MDA', 'Moldavie', 'Fédération moldave de football', NULL),
('MDV', 'Maldives', 'Fédération des Maldives de football', NULL),
('MEX', 'Mexique', 'Fédération du Mexique de football', 2),
('MKD', 'Macédoine', 'Fédération de Macédoine de football', 4),
('MLI', 'Mali', 'Fédération malienne de football', 1),
('MLT', 'Malte', 'Fédération de Malte de football', 4),
('MNE', 'Monténégro', 'Fédération du Monténégro de football', 4),
('MNG', 'Mongolie', 'Fédération de Mongolie de football', 5),
('MOZ', 'Mozambique', 'Fédération du Mozambique de football', 1),
('MRI', 'Maurice', 'Fédération de Maurice de football', NULL),
('MSR', 'Montserrat', 'Fédération de Montserrat de football', NULL),
('MTN', 'Mauritanie', 'Fédération de football de la République islamique de Mauritanie', 1),
('MYA', 'Birmanie', 'Fédération de Birmanie de football', 5),
('NAM', 'Namibie', 'Fédération de Namibie de football', 1),
('NCA', 'Nicaragua', 'Fédération du Nicaragua de football', 2),
('NCL', 'Nouvelle-Calédonie', 'Fédération calédonienne de football', NULL),
('NED', 'Pays-Bas', 'Fédération royale néerlandaise de football', 4),
('NEP', 'Népal', 'Fédération du Népal de football', 5),
('NGA', 'Nigéria', 'Fédération du Nigeria de football', 1),
('NIG', 'Niger', 'Fédération nigérienne de football', 1),
('NIR', 'Irlande du Nord', 'Association irlandaise de football', 4),
('NOR', 'Norvège', 'Fédération de Norvège de football', 4),
('NZL', 'Nouvelle-Zélande', 'Fédération de Nouvelle-Zélande de football', 5),
('OMA', 'Oman', 'Fédération d\'Oman de football', NULL),
('PAK', 'Pakistan', 'Fédération du Pakistan de football', 5),
('PAN', 'Panama', 'Fédération du Panama de football', 2),
('PAR', 'Paraguay', 'Association paraguayenne de football', 2),
('PER', 'Pérou', 'Fédération péruvienne de football', 3),
('PHI', 'Philippines', 'Fédération des Philippines de football', 5),
('PLE', 'Palestine', 'Fédération de Palestine de football', 5),
('PNG', 'Papouasie-Nouvelle-Guinée', 'Fédération papouane-néo-guinéenne de football', NULL),
('POL', 'Pologne', 'Fédération polonaise de football', 4),
('POR', 'Portugal', 'Fédération portugaise de football', 4),
('PRK', 'Corée du Nord', 'Fédération de football de la République populaire démocratique de Corée', 5),
('PUR', 'Porto Rico', 'Fédération de Porto Rico de football', NULL),
('QAT', 'Qatar', 'Fédération du Qatar de football', 5),
('ROU', 'Roumanie', 'Fédération roumaine de football', 4),
('RSA', 'Afrique du Sud', 'Fédération sud-africaine de football', 1),
('RUS', 'Russie', 'Fédération de Russie de football', 4),
('RWA', 'Rwanda', 'Fédération Rwandaise de Football Association', 1),
('SAM', 'Samoa', 'Fédération des Samoa de football', 1),
('SCO', 'Écosse', 'Fédération écossaise de football', 4),
('SEN', 'Sénégal', 'Fédération sénégalaise de football', 1),
('SEY', 'Seychelles', 'Fédération des Seychelles de football', 4),
('SIN', 'Singapour', 'Fédération de Singapour de football', NULL),
('SKN', 'Saint-Christophe-et-Niévès', 'Fédération de Saint-Christophe-et-Niévès de football', NULL),
('SLE', 'Sierra Leone', 'Fédération de Sierra Leone de football', NULL),
('SLV', 'Salvador', 'Fédération du Salvador de football', 2),
('SMR', 'Saint-Marin', 'Fédération de Saint-Marin de football', 2),
('SOL', 'Îles Salomon', 'Fédération des Salomon de football', NULL),
('SOM', 'Somalie', 'Fédération de Somalie de football', 1),
('SRB', 'Serbie', 'Fédération de Serbie de football', 4),
('SRI', 'Sri Lanka', 'Fédération du Sri Lanka de football', 5),
('SSD', 'Soudan du Sud', 'Fédération de football du Soudan du Sud', NULL),
('STP', 'Sao Tomé-et-Principe', 'Fédération de Sao Tomé-et-Principe de football', NULL),
('SUI', 'Suisse', 'Association suisse de football', 4),
('SUR', 'Suriname', 'Fédération du Suriname de football', NULL),
('SVK', 'Slovaquie', 'Fédération slovaque de football', 4),
('SVN', 'Slovénie', 'Fédération de Slovénie de football', 4),
('SWE', 'Suède', 'Fédération suédoise de football', 4),
('SYR', 'Syrie', 'Fédération de Syrie de football', 5),
('TAH', 'Tahiti', 'Fédération tahitienne de football', NULL),
('TAN', 'Tanzanie', 'Fédération de Tanzanie de football', 1),
('TCA', 'Îles Turques-et-Caïques', 'Fédération des Îles Turques-et-Caïques de football', NULL),
('TGA', 'Tonga', 'Fédération des Tonga de football', 5),
('THA', 'Thaïlande', 'Fédération de Thaïlande de football', 5),
('TJK', 'Tadjikistan', 'Fédération du Tadjikistan de football', 5),
('TKM', 'Turkménistan', 'Fédération du Turkménistan de football', 5),
('TLS', 'Timor oriental', 'Fédération du Timor oriental de football', NULL),
('TOG', 'Togo', 'Fédération togolaise de football', 1),
('TPE', 'Taïwan', 'Fédération de Taipei chinois de football', NULL),
('TUN', 'Tunisie', 'Fédération tunisienne de football', 1),
('TUR', 'Turquie', 'Fédération de Turquie de football', 4),
('UAE', 'Émirats arabes unis', 'Fédération des Émirats arabes unis de football', 5),
('UGA', 'Ouganda', 'Fédération d\'Ouganda de football', 1),
('UKR', 'Ukraine', 'Fédération de football d\'Ukraine', 4),
('URU', 'Uruguay', 'Association uruguayenne de football', 3),
('USA', 'États-Unis', 'Fédération des États-Unis de soccer', 2),
('UZB', 'Ouzbékistan', 'Fédération d\'Ouzbékistan de football', 5),
('VAN', 'Vanuatu', 'Fédération du Vanuatu de football', 5),
('VEN', 'Venezuela', 'Fédération vénézuélienne de football', 3),
('VIE', 'Viêt Nam', 'Fédération du Viêt Nam de football', 5),
('VIN', 'Saint-Vincent-et-les-Grenadines', 'Fédération de Saint-Vincent-et-les-Grenadines de football', NULL),
('WAL', 'Galles', 'Fédération de football de Galles', 4),
('YEM', 'Yémen', 'Fédération du Yémen de football', 1),
('ZAM', 'Zambie', 'Fédération de Zambie de football', 1),
('ZIM', 'Zimbabwe', 'Fédération du Zimbabwe de football', 1);

-- --------------------------------------------------------

--
-- Structure de la table `etapes`
--

CREATE TABLE `etapes` (
  `id_etape` tinyint(3) UNSIGNED NOT NULL,
  `etape` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `etapes`
--

INSERT INTO `etapes` (`id_etape`, `etape`) VALUES
(0, 'Finale'),
(1, 'Petite finale'),
(2, 'Demi-finale'),
(4, 'Quart de finale'),
(8, 'Huitième de finale'),
(9, 'Phase de groupes');

-- --------------------------------------------------------

--
-- Structure de la table `joueurs`
--

CREATE TABLE `joueurs` (
  `id_joueur` int(10) UNSIGNED NOT NULL,
  `equipe` varchar(3) NOT NULL,
  `prenom` varchar(64) NOT NULL,
  `nom` varchar(64) NOT NULL,
  `naissance` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `joueurs`
--

INSERT INTO `joueurs` (`id_joueur`, `equipe`, `prenom`, `nom`, `naissance`) VALUES
(1, 'RUS', 'Iouri', 'Gazinski', '1989-07-20'),
(2, 'RUS', 'Aleksandr', 'Golovine', '1996-05-30'),
(3, 'RUS', 'Denis', 'Cheryshev', '1990-12-26'),
(4, 'RUS', 'Roman', 'Zobnine', '1994-02-11'),
(5, 'RUS', 'Artyom', 'Dziouba', '1988-08-22'),
(6, 'URU', 'José', 'Giménez', '1995-01-20'),
(7, 'URU', 'Carlos', 'Sánchez', '1984-12-02'),
(8, 'EGY', 'Ahmed', 'Fathi', '1984-11-10'),
(9, 'RUS', 'Mário', 'Fernandes', '1990-09-19'),
(10, 'RUS', 'Ilia', 'Koutepov', '1993-07-29'),
(11, 'EGY', 'Mohamed', 'Salah', '1992-06-15'),
(12, 'URU', 'Luis', 'Suárez', '1987-01-24'),
(13, 'URU', 'Edinson', 'Cavani', '1987-02-14'),
(14, 'EGY', 'Abdallah', 'Saïd', '1985-07-13'),
(15, 'KSA', 'Salman', 'Al-Faraj', '1989-08-01'),
(16, 'KSA', 'Salem', 'Al-Dossari', '1991-08-19'),
(17, 'KSA', 'Abdullah', 'Otayf', '1992-08-03'),
(18, 'MAR', 'Aziz', 'Bouhaddouz', '1987-03-30'),
(19, 'POR', 'Christiano', 'Ronaldo', '1985-02-05'),
(20, 'POR', 'Gonçalo', 'Guedes', '1996-11-29'),
(21, 'ESP', 'Diego', 'Costa', '1988-10-07'),
(22, 'ESP', 'Sergio', 'Busquets', '1988-11-16'),
(23, 'ESP', 'José Ignacio', 'Nacho', '1990-01-18'),
(24, 'POR', 'João', 'Moutinho', '1986-09-08'),
(25, 'POR', 'Ricardo', 'Quaresma', '1983-09-26'),
(26, 'POR', 'Adrien', 'Silva', '1989-03-15'),
(27, 'IRN', 'Karim', 'Ansafirad', '1990-04-03'),
(28, 'MAR', 'Khalid', 'Boutaïb', '1987-04-24'),
(29, 'ESP', 'Francisco', 'Isco', '1992-04-21'),
(30, 'ESP', 'Andrés', 'Iniesta', '1984-05-11'),
(31, 'MAR', 'Youssef', 'En-Nesyri', '1997-06-01'),
(32, 'MAR', 'Fayçal', 'Fajr', '1988-08-01'),
(33, 'ESP', 'Iago', 'Aspas', '1987-08-01'),
(34, 'ESP', 'Dani', 'Carvajal', '1992-01-11'),
(35, 'FRA', 'Antoine', 'Griezmann', '1991-03-21'),
(36, 'AUS', 'Aziz', 'Behich', '1990-12-16'),
(37, 'AUS', 'Mile', 'Jedinak', '1984-08-03'),
(38, 'DEN', 'Yussuf', 'Poulsen', '1994-06-15'),
(39, 'DEN', 'Christian', 'Eriksen', '1992-02-14'),
(40, 'DEN', 'Nicolai', 'Jørgensen', '1991-01-15'),
(41, 'FRA', 'Kylian', 'Mbappé', '1998-12-20'),
(42, 'PER', 'Paolo', 'Guerrero', '1984-01-01'),
(43, 'PER', 'André', 'Carrillo', '1991-06-14'),
(44, 'ARG', 'Sergio', 'Agüero', '1988-06-02'),
(45, 'ARG', 'Marcos', 'Rojo', '1990-03-20'),
(46, 'ISL', 'Alfreð', 'Finnbogason', '1989-02-01'),
(47, 'NGA', 'Oghenekaro', 'Etebo', '1995-11-09'),
(48, 'CRO', 'Luka', 'Modrić', '1985-09-09'),
(49, 'CRO', 'Ante', 'Rebić', '1993-09-21'),
(50, 'CRO', 'Marcelo', 'Brozović', '1992-11-16'),
(51, 'CRO', 'Ivan', 'Rakitić', '1988-03-10'),
(52, 'CRO', 'Mateo', 'Kovačić', '1994-05-06'),
(53, 'NGA', 'Ahmed', 'Musa', '1992-10-14'),
(54, 'NGA', 'Victor', 'Moses', '1990-12-12'),
(55, 'NGA', 'Kenneth', 'Omeruo', '1993-10-17'),
(56, 'ARG', 'Lionel', 'Messi', '1987-06-24'),
(57, 'ARG', 'Éver', 'Banega', '1988-06-29'),
(58, 'ARG', 'Gabriel', 'Mercado', '1987-03-18'),
(59, 'ISL', 'Gylfi ', 'Sigurðsson', '1989-09-08'),
(60, 'CRO', 'Milan', 'Badelj', '1989-02-25'),
(61, 'CRO', 'Josip', 'Pivarić', '1989-01-30'),
(62, 'CRO', 'Ivan', 'Perišić', '1989-02-02'),
(63, 'SRB', 'Aleksandar', 'Kolarov', '1985-11-10'),
(64, 'BRA', 'Philippe', 'Coutinho', '1992-06-12'),
(65, 'SUI', 'Steven', 'Zuber', '1991-08-17'),
(66, 'SUI', 'Xherdan', 'Shaqiri', '1991-10-10'),
(67, 'BRA', 'Gabriel', 'Jesus', '1997-04-03'),
(68, 'BRA', '', 'Neymar', '1992-02-05'),
(69, 'BRA', 'Douglas', 'Costa', '1990-09-14'),
(70, 'SRB', 'Dušan', 'Tadić', '1988-11-20'),
(71, 'SRB', 'Aleksandar', 'Mitrović', '1994-09-16'),
(72, 'BRA', '', 'Paulinho', '1988-07-25'),
(73, 'BRA', 'Thiago', 'Silva', '1984-09-22'),
(74, 'SUI', 'Granit', 'Xhaka', '1992-09-27'),
(75, 'SUI', 'Mario', 'Gavranović', '1989-11-24'),
(76, 'SUI', 'Blerim', 'Džemaili', '1986-04-12'),
(77, 'SUI', 'Breel', 'Embolo', '1997-02-14'),
(78, 'SUI', 'Josip', 'Drmić', '1992-08-08'),
(79, 'SUI', 'Denis', 'Zakaria', '1996-11-20'),
(80, 'CRC', 'Kendall', 'Waston', '1988-01-01'),
(81, 'CRC', 'Joel', 'Campbell', '1992-06-26'),
(82, 'SUI', 'Yann', 'Sommer', '1988-12-17'),
(83, 'MEX', 'Hirving', 'Lozano', '1995-07-30'),
(84, 'MEX', 'Javier', 'Hernández', '1988-06-01'),
(85, 'SWE', 'Andreas', 'Granqvist', '1985-04-16'),
(86, 'MEX', 'Carlos', 'Vela', '1989-03-01'),
(87, 'KOR', 'Heung-min', 'Son', '1992-07-08'),
(88, 'KOR', 'Jae-sung', 'Lee', '1992-08-10'),
(89, 'SWE', 'Ola', 'Toivonen', '1986-07-03'),
(90, 'GER', 'Marco', 'Reus', '1989-05-31'),
(91, 'GER', 'Mario', 'Gómez', '1985-07-10'),
(92, 'GER', 'Toni', 'Kroos', '1990-01-04'),
(93, 'KOR', 'Young-gwon', 'Kim', '1990-02-27'),
(94, 'KOR', 'Se-jong', 'Ju', '1990-10-30'),
(95, 'SWE', 'Ludwig', 'Augustinsson', '1994-04-21'),
(96, 'SWE', 'Viktor', 'Claesson', '1992-01-02'),
(97, 'MEX', 'Edson', 'Álvarez', '1997-10-24'),
(98, 'BEL', 'Dries', 'Mertens', '1987-05-06'),
(99, 'BEL', 'Romelu', 'Lukaku', '1993-05-13'),
(100, 'BEL', 'Kevin', 'De Bruyne', '1991-06-28'),
(101, 'BEL', 'Eden', 'Hazard', '1991-01-07'),
(102, 'ENG', 'Harry', 'Kane', '1993-07-28'),
(103, 'ENG', 'Harry', 'Maguire', '1993-03-05'),
(104, 'TUN', 'Ferjani', 'Sassi', '1992-03-18'),
(105, 'TUN', 'Hamdi', 'Nagguez', '1992-10-28'),
(106, 'TUN', 'Wahbi', 'Khazri', '1991-02-08'),
(107, 'TUN', 'Dylan', 'Bronn', '1995-06-19'),
(108, 'BEL', 'Thomas', 'Meunier', '1991-09-12'),
(109, 'BEL', 'Toby', 'Alderweireld', '1989-03-02'),
(110, 'BEL', 'Michy', 'Batshuayi', '1993-10-02'),
(111, 'BEL', 'Youri', 'Tielemans', '1997-05-07'),
(112, 'BEL', 'Adnan', 'Januzaj', '1995-02-05'),
(113, 'ENG', 'John', 'Stones', '1994-05-28'),
(114, 'ENG', 'Kieran', 'Trippier', '1990-09-19'),
(115, 'ENG', 'Jesse', 'Lingard', '1992-12-15'),
(116, 'ENG', 'Raheem', 'Sterling', '1994-12-08'),
(117, 'PAN', 'Ricardo', 'Ávila', '1997-02-04'),
(118, 'PAN', 'Felipe', 'Baloy', '1981-02-24'),
(119, 'TUN', 'Yassine', 'Meriah', '1993-07-02'),
(120, 'TUN', 'Fakhreddine', 'Ben Youssef', '1991-06-23'),
(121, 'TUN', 'Oussama', 'Haddadi', '1992-01-28'),
(122, 'COL', 'Juan Fernando', 'Quintero', '1993-01-18'),
(123, 'JPN', 'Shinji', 'Kagawa', '1989-03-17'),
(124, 'JPN', 'Yuya', 'Osako', '1990-05-18'),
(125, 'JPN', 'Keisuke', 'Honda', '1986-06-13'),
(126, 'POL', 'Thiago', 'Cionek', '1986-04-21'),
(127, 'POL', 'Kamil', 'Grosicki', '1988-06-08'),
(128, 'POL', 'Grzegorz', 'Krychowiak', '1990-01-29'),
(129, 'SEN', 'M\'Baye', 'Niang', '1993-12-19'),
(130, 'JPN', 'Takashi', 'Inui', '1988-06-02'),
(131, 'JPN', 'Yūto', 'Nagatomo', '1986-09-12'),
(132, 'SEN', 'Sadio', 'Mané', '1992-04-10'),
(133, 'SEN', 'Moussa', 'Wagué', '1998-10-04'),
(134, 'COL', 'James', 'Rodríguez', '1991-07-12'),
(135, 'COL', 'Yerry', 'Mina', '1994-09-23'),
(136, 'COL', 'Radamel', 'Falcao', '1986-02-10'),
(137, 'COL', 'Juan', 'Cuadrado', '1988-05-26'),
(138, 'POL', 'Jan', 'Bednarek', '1996-04-12'),
(139, 'POL', 'Rafał', 'Kurzawa', '1993-01-29'),
(142, 'URU', 'Rodrigo', 'Bentancur', '1997-06-25'),
(143, 'POR', 'Raphaël', 'Guerreiro', '1993-12-22'),
(144, 'POR', '', 'Pepe', '1983-02-26'),
(145, 'FRA', 'Benjamin', 'Pavard', '1996-03-28'),
(146, 'FRA', 'Lucas', 'Hernandez', '1996-02-14'),
(147, 'FRA', 'Olivier', 'Giroud', '1986-09-30'),
(148, 'ARG', 'Ángel', 'Di María', '1988-02-14'),
(150, 'RUS', 'Sergueï', 'Ignachevitch', '1979-07-14'),
(151, 'DEN', 'Mathias', 'Jørgensen', '1990-04-23'),
(152, 'DEN', 'Thomas', 'Delaney', '1991-09-03'),
(153, 'CRO', 'Mario', 'Mandžukić', '1986-05-21'),
(154, 'BRA', '', 'Willian', '1988-08-09'),
(155, 'BRA', 'Robert', 'Firmino', '1991-10-02'),
(156, 'BEL', 'Jan', 'Vertonghen', '1987-04-24'),
(157, 'BEL', 'Marouane', 'Fellaini', '1987-11-22'),
(158, 'BEL', 'Nacer', 'Chadli', '1989-08-02'),
(159, 'JPN', 'Genki', 'Haraguchi', '1991-05-09'),
(160, 'JPN', 'Gaku', 'Shibasaki', '1992-05-28'),
(161, 'SWE', 'Emil', 'Forsberg', '1991-10-23'),
(162, 'FRA', 'Raphaël', 'Varane', '1991-04-25'),
(163, 'FRA', 'Corentin', 'Tolisso', '1994-08-03'),
(164, 'BRA', '', 'Fernandinho', '1985-05-04'),
(165, 'BRA', 'Renato', 'Augusto', '1988-02-01'),
(166, 'ENG', 'Ashley', 'Young', '1985-07-09'),
(167, 'ENG', 'Dele', 'Alli', '1996-04-11'),
(169, 'RUS', 'Alan', 'Dzagoïev', '1990-06-17'),
(171, 'CRO', 'Andrej', 'Kramarić', '1990-09-19'),
(172, 'CRO', 'Domagoj', 'Vida', '1989-04-29'),
(173, 'RUS', 'Fiodor', 'Smolov', '1990-02-09'),
(174, 'RUS', 'Daler', 'Kouziaïev', '1993-01-15'),
(175, 'COL', 'Luis', 'Muriel', '1991-04-16'),
(176, 'COL', 'Mateus', 'Uribe', '1991-03-21'),
(177, 'COL', 'Carlos', 'Bacca', '1986-09-08'),
(178, 'ENG', 'Marcus', 'Rashford', '1997-10-31'),
(179, 'ENG', 'Jordan', 'Henderson', '1990-06-17'),
(180, 'ENG', 'Eric', 'Dier', '1994-01-15'),
(181, 'DEN', 'Simon', 'Kjær', '1989-03-26'),
(182, 'DEN', 'Michael', 'Krohn-Dehli', '1983-04-28'),
(183, 'DEN', 'Lasse', 'Schöne', '1986-05-27'),
(184, 'FRA', 'Samuel', 'Umtiti', '1993-11-14'),
(185, 'CRO', 'Šime', 'Vrsaljko', '1992-01-10'),
(186, 'FRA', 'Paul', 'Pogba', '1993-03-15'),
(187, 'BEL', 'Vincent', 'Kompany', '1986-04-10'),
(188, 'BEL', 'Axel', 'Witsel', '1989-01-12'),
(189, 'FRA', 'Hugo', 'Lloris', '1986-12-26'),
(190, 'BEL', 'Thibaut', 'Courtois', '1992-05-11'),
(191, 'ENG', 'Jordan', 'Pickford', '1994-03-07'),
(192, 'SUI', 'Michael', 'Lang', '1991-02-08'),
(193, 'SWE', 'Martin', 'Olsson', '1988-05-17'),
(194, 'SUI', 'Manuel', 'Akanji', '1995-07-19'),
(196, 'URU', 'Martín', 'Cáceres', '1987-04-07'),
(197, 'URU', 'Fernando', 'Muslera', '1986-06-16'),
(198, 'DEN', 'Kasper', 'Schmeichel', '1986-11-05'),
(199, 'CRO', 'Danijel', 'Subašić', '1984-10-07'),
(200, 'ESP', 'Gerard', 'Piqué', '1987-02-02'),
(201, 'RUS', 'Igor', 'Akinfeïev', '1986-04-08'),
(202, 'POR', 'Rui', 'Patrício', '1988-02-15'),
(203, 'URU', 'Carlos Andrés', 'Sánchez', '1984-12-02'),
(204, 'FRA', 'N\'Golo', 'Kanté', '1991-03-29'),
(205, 'ISL', 'Hannes', 'Halldórsson', '1984-04-27'),
(206, 'MAR', 'Amine', 'Harit', '1997-06-18'),
(207, 'GER', 'Jérôme', 'Boateng', '1988-09-03'),
(208, 'RUS', 'Igor', 'Smolnikov', '1988-08-09'),
(209, 'SWE', 'Sebastian', 'Larsson', '1985-06-06'),
(210, 'ENG', 'Kyle', 'Walker', '1990-05-28'),
(211, 'ARG', 'Javier', 'Mascherano', '1984-06-08'),
(212, 'ARG', 'Nicolás', 'Otamendi', '1988-02-12'),
(213, 'BRA', '', 'Casemiro', '1992-02-23'),
(214, 'COL', 'Wílmar', 'Barrios', '1993-10-16'),
(215, 'KOR', 'Woo-young', 'Jung', '1989-12-14'),
(216, 'FRA', 'Blaise', 'Matuidi', '1987-04-09'),
(217, 'SWE', 'Mikael', 'Lustig', '1986-12-13'),
(218, 'BEL', 'Leander', 'Dendoncker', '1995-04-15'),
(219, 'SUI', 'Fabian', 'Schär', '1991-12-20'),
(220, 'PAN', 'Armando', 'Cooper', '1987-11-26');

-- --------------------------------------------------------

--
-- Structure de la table `matchs`
--

CREATE TABLE `matchs` (
  `id_match` int(10) UNSIGNED NOT NULL,
  `annee` smallint(5) UNSIGNED NOT NULL,
  `id_etape` tinyint(3) UNSIGNED NOT NULL DEFAULT '9',
  `equipe1` varchar(3) NOT NULL,
  `equipe2` varchar(3) NOT NULL,
  `score1` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `score2` tinyint(3) UNSIGNED NOT NULL DEFAULT '0',
  `prolongations` tinyint(1) NOT NULL DEFAULT '0',
  `tirs_au_but` tinyint(1) NOT NULL DEFAULT '0',
  `tab1` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'score de tirs au but',
  `tab2` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'score de tirs au but',
  `date` date NOT NULL,
  `id_stade` int(10) UNSIGNED NOT NULL,
  `spectateurs` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `matchs`
--

INSERT INTO `matchs` (`id_match`, `annee`, `id_etape`, `equipe1`, `equipe2`, `score1`, `score2`, `prolongations`, `tirs_au_but`, `tab1`, `tab2`, `date`, `id_stade`, `spectateurs`) VALUES
(1, 2018, 9, 'RUS', 'KSA', 5, 0, 0, 0, NULL, NULL, '2018-06-14', 2, 78011),
(2, 2018, 9, 'EGY', 'URU', 0, 1, 0, 0, NULL, NULL, '2018-06-15', 7, 27015),
(3, 2018, 9, 'RUS', 'EGY', 3, 1, 0, 0, NULL, NULL, '2018-06-19', 1, 64468),
(4, 2018, 9, 'URU', 'KSA', 1, 0, 0, 0, NULL, NULL, '2018-06-20', 9, 42678),
(5, 2018, 9, 'URU', 'RUS', 3, 0, 0, 0, NULL, NULL, '2018-06-25', 12, 41970),
(6, 2018, 9, 'KSA', 'EGY', 2, 1, 0, 0, NULL, NULL, '2018-06-25', 11, 36823),
(7, 2018, 9, 'MAR', 'IRN', 0, 1, 0, 0, NULL, NULL, '2018-06-15', 1, 62548),
(8, 2018, 9, 'POR', 'ESP', 3, 3, 0, 0, NULL, NULL, '2018-06-15', 10, 43866),
(9, 2018, 9, 'POR', 'MAR', 1, 0, 0, 0, NULL, NULL, '2018-06-20', 2, 78011),
(10, 2018, 9, 'IRN', 'ESP', 0, 1, 0, 0, NULL, NULL, '2018-06-20', 8, 42718),
(11, 2018, 9, 'IRN', 'POR', 1, 1, 0, 0, NULL, NULL, '2018-06-25', 6, 41685),
(12, 2018, 9, 'ESP', 'MAR', 2, 2, 0, 0, NULL, NULL, '2018-06-25', 5, 33973),
(13, 2018, 9, 'FRA', 'AUS', 2, 1, 0, 0, NULL, NULL, '2018-06-16', 8, 41279),
(14, 2018, 9, 'PER', 'DEN', 0, 1, 0, 0, NULL, NULL, '2018-06-16', 6, 40502),
(15, 2018, 9, 'DEN', 'AUS', 1, 1, 0, 0, NULL, NULL, '2018-06-21', 12, 40727),
(16, 2018, 9, 'FRA', 'PER', 1, 0, 0, 0, NULL, NULL, '2018-06-21', 7, 32789),
(17, 2018, 9, 'DEN', 'FRA', 0, 0, 0, 0, NULL, NULL, '2018-06-26', 2, 78011),
(18, 2018, 9, 'AUS', 'PER', 0, 2, 0, 0, NULL, NULL, '2018-06-26', 10, 44073),
(19, 2018, 9, 'ARG', 'ISL', 1, 1, 0, 0, NULL, NULL, '2018-06-16', 3, 44109),
(20, 2018, 9, 'CRO', 'NGA', 2, 0, 0, 0, NULL, NULL, '2018-06-16', 5, 31136),
(21, 2018, 9, 'ARG', 'CRO', 0, 3, 0, 0, NULL, NULL, '2018-06-21', 4, 43319),
(22, 2018, 9, 'NGA', 'ISL', 2, 0, 0, 0, NULL, NULL, '2018-06-21', 11, 40904),
(23, 2018, 9, 'NGA', 'ARG', 1, 2, 0, 0, NULL, NULL, '2018-06-26', 1, 64468),
(24, 2018, 9, 'ISL', 'CRO', 1, 2, 0, 0, NULL, NULL, '2018-06-26', 9, 43472),
(25, 2018, 9, 'CRC', 'SRB', 0, 1, 0, 0, NULL, NULL, '2018-06-17', 12, 41432),
(26, 2018, 9, 'BRA', 'SUI', 1, 1, 0, 0, NULL, NULL, '2018-06-17', 9, 43109),
(27, 2018, 9, 'BRA', 'CRC', 2, 0, 0, 0, NULL, NULL, '2018-06-22', 1, 64468),
(28, 2018, 9, 'SRB', 'SUI', 1, 2, 0, 0, NULL, NULL, '2018-06-22', 5, 33167),
(29, 2018, 9, 'SRB', 'BRA', 0, 2, 0, 0, NULL, NULL, '2018-06-27', 3, 44190),
(30, 2018, 9, 'SUI', 'CRC', 2, 2, 0, 0, NULL, NULL, '2018-06-27', 4, 43319),
(31, 2018, 9, 'GER', 'MEX', 0, 1, 0, 0, NULL, NULL, '2018-06-17', 2, 78011),
(32, 2018, 9, 'SWE', 'KOR', 1, 0, 0, 0, NULL, NULL, '2018-06-17', 4, 42300),
(33, 2018, 9, 'KOR', 'MEX', 1, 2, 0, 0, NULL, NULL, '2018-06-23', 9, 43472),
(34, 2018, 9, 'GER', 'SWE', 2, 1, 0, 0, NULL, NULL, '2018-06-23', 10, 44287),
(35, 2018, 9, 'KOR', 'GER', 2, 0, 0, 0, NULL, NULL, '2018-06-27', 8, 41835),
(36, 2018, 9, 'MEX', 'SWE', 0, 3, 0, 0, NULL, NULL, '2018-06-27', 7, 33061),
(37, 2018, 9, 'BEL', 'PAN', 3, 0, 0, 0, NULL, NULL, '2018-06-18', 10, 43257),
(38, 2018, 9, 'TUN', 'ENG', 1, 2, 0, 0, NULL, NULL, '2018-06-18', 11, 41064),
(39, 2018, 9, 'BEL', 'TUN', 5, 2, 0, 0, NULL, NULL, '2018-06-23', 3, 44190),
(40, 2018, 9, 'ENG', 'PAN', 6, 1, 0, 0, NULL, NULL, '2018-06-23', 4, 43319),
(41, 2018, 9, 'ENG', 'BEL', 0, 1, 0, 0, NULL, NULL, '2018-06-28', 5, 33973),
(42, 2018, 9, 'PAN', 'TUN', 1, 2, 0, 0, NULL, NULL, '2018-06-28', 6, 37168),
(43, 2018, 9, 'COL', 'JPN', 1, 2, 0, 0, NULL, NULL, '2018-06-19', 6, 40842),
(44, 2018, 9, 'POL', 'SEN', 1, 2, 0, 0, NULL, NULL, '2018-06-19', 3, 44190),
(45, 2018, 9, 'JPN', 'SEN', 2, 2, 0, 0, NULL, NULL, '2018-06-24', 7, 32572),
(46, 2018, 9, 'POL', 'COL', 0, 3, 0, 0, NULL, NULL, '2018-06-24', 8, 42873),
(47, 2018, 9, 'JPN', 'POL', 0, 1, 0, 0, NULL, NULL, '2018-06-28', 11, 42189),
(48, 2018, 9, 'SEN', 'COL', 0, 1, 0, 0, NULL, NULL, '2018-06-28', 12, 41970),
(49, 2018, 8, 'URU', 'POR', 2, 1, 0, 0, NULL, NULL, '2018-06-30', 10, 44287),
(50, 2018, 8, 'FRA', 'ARG', 4, 3, 0, 0, NULL, NULL, '2018-06-30', 8, 42873),
(51, 2018, 8, 'ESP', 'RUS', 1, 1, 1, 1, 3, 4, '2018-07-01', 2, 78011),
(52, 2018, 8, 'CRO', 'DEN', 1, 1, 1, 1, 3, 2, '2018-07-01', 4, 40851),
(53, 2018, 8, 'BRA', 'MEX', 2, 0, 0, 0, NULL, NULL, '2018-07-02', 12, 41970),
(54, 2018, 8, 'BEL', 'JPN', 3, 2, 0, 0, NULL, NULL, '2018-07-02', 9, 41466),
(55, 2018, 8, 'SWE', 'SUI', 1, 0, 0, 0, NULL, NULL, '2018-07-03', 1, 64042),
(56, 2018, 8, 'COL', 'ENG', 1, 1, 1, 1, 3, 4, '2018-07-03', 3, 44190),
(57, 2018, 4, 'URU', 'FRA', 0, 2, 0, 0, NULL, NULL, '2018-07-06', 4, 43319),
(58, 2018, 4, 'BRA', 'BEL', 1, 2, 0, 0, NULL, NULL, '2018-07-06', 8, 42873),
(59, 2018, 4, 'SWE', 'ENG', 0, 2, 0, 0, NULL, NULL, '2018-07-07', 12, 39991),
(60, 2018, 4, 'RUS', 'CRO', 2, 2, 1, 1, 3, 4, '2018-07-07', 10, 44287),
(61, 2018, 2, 'FRA', 'BEL', 1, 0, 0, 0, NULL, NULL, '2018-07-10', 1, 64286),
(62, 2018, 2, 'CRO', 'ENG', 2, 1, 1, 0, NULL, NULL, '2018-07-11', 2, 78011),
(63, 2018, 1, 'BEL', 'ENG', 2, 0, 0, 0, NULL, NULL, '2018-07-14', 1, 64406),
(64, 2018, 0, 'FRA', 'CRO', 4, 2, 0, 0, NULL, NULL, '2018-07-15', 2, 78011);

-- --------------------------------------------------------

--
-- Structure de la table `participations`
--

CREATE TABLE `participations` (
  `code` varchar(3) NOT NULL COMMENT 'équipes',
  `annee` smallint(5) UNSIGNED NOT NULL COMMENT 'championnats',
  `groupe` varchar(1) DEFAULT NULL,
  `organisateur` tinyint(1) DEFAULT NULL,
  `place` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `participations`
--

INSERT INTO `participations` (`code`, `annee`, `groupe`, `organisateur`, `place`) VALUES
('ARG', 2018, 'D', NULL, 16),
('AUS', 2018, 'C', NULL, 28),
('BEL', 2018, 'G', NULL, 3),
('BRA', 2018, 'E', NULL, 6),
('COL', 2018, 'H', NULL, 9),
('CRC', 2018, 'E', NULL, 28),
('CRO', 2018, 'D', NULL, 2),
('DEN', 2018, 'C', NULL, 11),
('EGY', 2018, 'A', NULL, 31),
('ENG', 2018, 'G', NULL, 4),
('ESP', 2018, 'B', NULL, 10),
('FRA', 2018, 'C', NULL, 1),
('GER', 2018, 'F', NULL, 22),
('IRN', 2018, 'B', NULL, 18),
('ISL', 2018, 'D', NULL, 28),
('JPN', 2018, 'H', NULL, 15),
('KOR', 2018, 'F', NULL, 19),
('KSA', 2018, 'A', NULL, 26),
('MAR', 2018, 'B', NULL, 27),
('MEX', 2018, 'F', NULL, 12),
('NGA', 2018, 'D', NULL, 21),
('PAN', 2018, 'G', NULL, 32),
('PER', 2018, 'C', NULL, 20),
('POL', 2018, 'H', NULL, 25),
('POR', 2018, 'B', NULL, 13),
('RUS', 2018, 'A', 1, 8),
('SEN', 2018, 'H', NULL, 17),
('SRB', 2018, 'E', NULL, 22),
('SUI', 2018, 'E', NULL, 14),
('SWE', 2018, 'F', NULL, 7),
('TUN', 2018, 'G', NULL, 24),
('URU', 2018, 'A', NULL, 5);

-- --------------------------------------------------------

--
-- Structure de la table `stades`
--

CREATE TABLE `stades` (
  `id_stade` int(10) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `localite` varchar(255) NOT NULL,
  `pays` varchar(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `stades`
--

INSERT INTO `stades` (`id_stade`, `nom`, `localite`, `pays`) VALUES
(1, 'Stade Krestovski de Saint-Pétersbourg', 'Saint-Pétersbourg', 'RUS'),
(2, 'Stade Loujniki', 'Moscou', 'RUS'),
(3, 'Stade du Spartak', 'Moscou', 'RUS'),
(4, 'Stade de Nijni Novgorod', 'Nijni Novgorod', 'RUS'),
(5, 'Stade de Kaliningrad', 'Kaliningrad', 'RUS'),
(6, 'Stade de Mordovie', 'Saransk', 'RUS'),
(7, 'Iekaterinbourg Arena', 'Iekaterinbourg', 'RUS'),
(8, 'Kazan Arena', 'Kazan', 'RUS'),
(9, 'Rostov Arena', 'Rostov-sur-le-Don', 'RUS'),
(10, 'Stade Ficht', 'Sotchi', 'RUS'),
(11, 'Volgograd Arena', 'Volgograd', 'RUS'),
(12, 'Samara Arena', 'Samara', 'RUS');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `buts`
--
ALTER TABLE `buts`
  ADD PRIMARY KEY (`id_but`);

--
-- Index pour la table `championnats`
--
ALTER TABLE `championnats`
  ADD PRIMARY KEY (`annee`);

--
-- Index pour la table `continents`
--
ALTER TABLE `continents`
  ADD PRIMARY KEY (`id_continent`);

--
-- Index pour la table `equipes`
--
ALTER TABLE `equipes`
  ADD PRIMARY KEY (`code`);

--
-- Index pour la table `etapes`
--
ALTER TABLE `etapes`
  ADD PRIMARY KEY (`id_etape`);

--
-- Index pour la table `joueurs`
--
ALTER TABLE `joueurs`
  ADD PRIMARY KEY (`id_joueur`);

--
-- Index pour la table `matchs`
--
ALTER TABLE `matchs`
  ADD PRIMARY KEY (`id_match`);

--
-- Index pour la table `participations`
--
ALTER TABLE `participations`
  ADD PRIMARY KEY (`code`,`annee`);

--
-- Index pour la table `stades`
--
ALTER TABLE `stades`
  ADD PRIMARY KEY (`id_stade`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `buts`
--
ALTER TABLE `buts`
  MODIFY `id_but` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=170;

--
-- AUTO_INCREMENT pour la table `joueurs`
--
ALTER TABLE `joueurs`
  MODIFY `id_joueur` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=221;

--
-- AUTO_INCREMENT pour la table `matchs`
--
ALTER TABLE `matchs`
  MODIFY `id_match` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT pour la table `stades`
--
ALTER TABLE `stades`
  MODIFY `id_stade` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
