import unittest
from unittest.mock import patch
import io
import sys
import os
#Partie 0 : Initialisation des variables
descriptions = {
        "grappin": "Parfait pour escalader les gratte-ciel de Gotham ou attraper un sandwich dans le frigo à distance.",
        "batarang": "Idéal pour désarmer les méchants, ou couper la pizza les vendredis soirs.",
        "batmobile": "Le moyen de transport le plus cool et le moins discret pour naviguer dans Gotham. Attention aux bouchons !"
    }

def analyser_gadget(nom_gadget):
    if nom_gadget in descriptions: # Si le gadget est dans le dictionnaire
        return descriptions[nom_gadget] # On retourne la description
    else:
        return "Gadget inconnu. Alfred, on a du travail !" # Sinon on retourne un message d'erreur


def count_gadgets(file):  # Fonction pour compter les occurences
    occurences = {}  # Initialisation d'un dictionnaire tampon
    with open(file, 'r') as registre:  # Ouverture du fichier
        bat_gadgets = registre.readlines()  # Lecture du fichier
        i = 0
    for element in bat_gadgets:
        bat_gadgets[i] = element.rstrip("\n").lower()
        i += 1

    for line in bat_gadgets: # Pour chaque ligne du fichier
        if line == "jokerbox" or line == "JokerBox":
            pass
        elif line in occurences: # Si la ligne est dans le dictionnaire
            occurences[line] += 1 # On ajoute 1 à la valeur
        else:
            occurences[line] = 1 # Sinon on crée une nouvelle entrée dans le dictionnaire
    return occurences




def bat_signal():
    answer = ""
    while answer != "quit":
        answer = input("Avez vous besoin de batman ? si oui tapez oui; si non tapez non; pour quitter ce menu taper quit : ")
        if answer == "oui":
            print("Batman est en route !")
        elif answer == "non":
            print("Gotham est en sécurité pour le moment.")
        elif answer == "quit":
            print("Batman prend une pause-café.")
        else:
            print("Je ne comprends pas votre demande, veuillez réessayer.")
    return


def ajouter_gadget(nom_gadget, description):
    if nom_gadget not in descriptions:
        descriptions[nom_gadget] = description
    elif nom_gadget in descriptions:
        print("Ce gadget se situe déja la :( ")

    for key in descriptions:
        print(key, "->", descriptions[key])


def supprimer_gadget(nom_gadget):
    if nom_gadget in descriptions:
        del descriptions[nom_gadget]
    elif nom_gadget not in descriptions:
        print("nous ne parvenons pas a trouver et supprimer",nom_gadget)

    for key in descriptions:
        print(key, "->", descriptions[key])


def modifier_gadget(nom_gadget, nouvelle_description):
    if nom_gadget in descriptions:
        descriptions[nom_gadget] = nouvelle_description

        for key in descriptions:
            print(key, "->", descriptions[key])
    elif nom_gadget not in descriptions:
        question = input("Ce gadget ne se situe pas dans la liste, voulez vous l'ajouter ? oui/non : ")
        if question == "oui":
            ajouter_gadget(nom_gadget, nouvelle_description)
        elif question == "non":
            print("pas de problème !")
        else:
            print("vous me posez une colle..")

def afficher_gadgets():
    for key in descriptions:
        print(key, ":", descriptions[key])


class TestExamBlanc23(unittest.TestCase):

    def test_analyser_gadget(self):
        self.assertEqual(analyser_gadget("grappin"), "Parfait pour escalader les gratte-ciel de Gotham ou attraper un sandwich dans le frigo à distance.")
        self.assertEqual(analyser_gadget("batarang"), "Idéal pour désarmer les méchants, ou couper la pizza les vendredis soirs.")
        self.assertEqual(analyser_gadget("batmobile"), "Le moyen de transport le plus cool et le moins discret pour naviguer dans Gotham. Attention aux bouchons !")
        self.assertEqual(analyser_gadget("inconnu"), "Gadget inconnu. Alfred, on a du travail !")
 
    def test_count_gadgets(self):
        with open("bat_registre_test.txt", "w") as fichier_test:
            fichier_test.write('grappin\nbatmobile\nalfredcap\nbatarang\nbatCaveCommande\ngrappin\nbatmobile\nbatmobile\n')

        gadget_counts = count_gadgets('bat_registre_test.txt')
        os.remove("bat_registre_test.txt")
        self.assertIsInstance(gadget_counts, dict)
        for gadget, occurrences in gadget_counts.items():
            self.assertIsInstance(gadget, str)
            self.assertIsInstance(occurrences, int)
        self.assertEqual(gadget_counts.get("grappin"), 2)
        self.assertEqual(gadget_counts.get("batarang"), 1)
        self.assertEqual(gadget_counts.get("batmobile"), 3)
        self.assertIsNone(gadget_counts.get("jokerbox"))
        self.assertIsNone(gadget_counts.get(''))
    
    @patch('builtins.input', side_effect=['oui', 'non', 'quit'])
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_bat_signal(self, mock_stdout, mock_input):
        bat_signal()
        output = mock_stdout.getvalue()
        self.assertIn("Batman est en route !", output)
        self.assertIn("Gotham est en sécurité pour le moment.", output)
        self.assertIn("Batman prend une pause-café.", output)

    def test_ajouter_gadget(self):
        ajouter_gadget("jokerbox", "Un gadget diabolique utilisé par le Joker.")
        self.assertEqual(descriptions.get("jokerbox"), "Un gadget diabolique utilisé par le Joker.")

    def test_supprimer_gadget(self):
        supprimer_gadget("grappin")
        self.assertNotIn("grappin", descriptions)

    def test_modifier_gadget(self):
        modifier_gadget("batarang", "Idéal pour désarmer les méchants, ou couper la pizza les samedis soirs.")
        self.assertEqual(descriptions.get("batarang"), "Idéal pour désarmer les méchants, ou couper la pizza les samedis soirs.")

    def test_afficher_gadgets(self):
        with patch('sys.stdout', new_callable=io.StringIO) as mock_stdout:
            afficher_gadgets()
            output = mock_stdout.getvalue()
            self.assertIn("grappin : Parfait pour escalader les gratte-ciel de Gotham ou attraper un sandwich dans le frigo à distance.", output)
            self.assertIn("batarang : Idéal pour désarmer les méchants, ou couper la pizza les vendredis soirs.", output)
            self.assertIn("batmobile : Le moyen de transport le plus cool et le moins discret pour naviguer dans Gotham. Attention aux bouchons !", output)

if __name__ == '__main__':
    unittest.main()
