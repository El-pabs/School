# def volboite(a=10, b=10, c=10):
#     return a*b*c
# print(volboite())
# print(volboite(5.2))
# print(volboite(5.2,3))

# def changeCar(ch, ca1,ca2, debut=0, fin=0):
#     lst=[*ch]
#
#     if not fin:
#         fin=len(lst)
#
#     for i in range(debut, fin):
#         if lst==ca1:
#

#
#
# print(changeCar("coucou comment ca va"," ","+"))


# def is_prime(num):   #création de la fonction
#     liste =[]
#     for i in range (2, num+1):      #on donne a i chaque valeur entre 2 et mon nombre
#         if i==num:         #on regarde si i vaut mon nombre de base et si il n'y a eu aucun autre nombre qui l'a divisé grâce à a 0
#             if len(liste)<1:       #si ma liste est plus petite que 1 (donc 0) mon nombre n'a pas pu etre divisé une seul fois
#                 print("the number",i, "is prime")
#                 break
#             elif len(liste)>=1:         #si mon nombre n'a pas été divisé que par lui meme alors on imprime la liste pour montrer a cause de quelle nombre
#                 print("this number is not prime because of all the following numbers :", liste)
#         if num%i==0:                  #si mon nombre est divisible entièrement par un nombre alors il n'est pas premier (sauf lui même)
#             liste.append(i)            #on place la valeur dans la liste car il divise entièrement notre numéro
#         else:
#             None
# is_prime(int(input('le nombre chef')))         #appel de la fonction


# tup = (1,2,3,2,4,5,6,2,7,2,8,9)
# duplicate= tup.count(2)
# print (duplicate)

# d1 = {"Johan" : "A", "Erwin" : "B"}
# d2 = {"Fab" : "A", "Joakim" : "C"}
# d3 = {}
# for item in (d1, d2):
#     d3.update(d1)
#     d3.update(d2)
#
# print (d3)
#
#
# from random import randrange
#
# move_joueur = []
# move_pc = [5, ]
# case_utiliser = [5, ]
# tempo = 0
# game = 0
#
# valeur_jeu = {1: "1",
#               2: "2",
#               3: "3",
#               4: "4",
#               5: "x",
#               6: "6",
#               7: "7",
#               8: "8",
#               9: "9"}
#
#
# def display_board():
#     print("""
#             +--------+-------+---------+
#             I        I        I        I
#             I   {}    I   {}    I   {}    I
#             I        I        I        I
#             +--------+-------+---------+
#             I        I        I        I
#             I   {}    I   {}    I    {}   I
#             I        I        I        I
#             +--------+-------+---------+
#             I        I        I        I
#             I   {}    I   {}    I   {}    I
#             I        I        I        I
#             +--------+-------+---------+
#
#             """.format(valeur_jeu.get(1),
#                        valeur_jeu.get(2),
#                        valeur_jeu.get(3),
#                        valeur_jeu.get(4),
#                        valeur_jeu.get(5),
#                        valeur_jeu.get(6),
#                        valeur_jeu.get(7),
#                        valeur_jeu.get(8),
#                        valeur_jeu.get(9)
#                        ))
#
#
# def enter_move():
#     case_joueur = int(input("quelle case ? : "))
#     if case_joueur in case_utiliser:
#         enter_move()
#     else:
#         valeur_jeu[case_joueur] = "0"
#         case_utiliser.append(case_joueur)
#         move_joueur.append(case_joueur)
#
#
# def victory_for():
#     global game
#     win_move = [[1, 2, 3],
#                 [4, 5, 6],
#                 [7, 8, 9],
#                 # horizontal
#                 [1, 4, 7],
#                 [2, 5, 8],
#                 [3, 6, 9],
#                 # vertical
#                 [1, 5, 9],
#                 [3, 5, 7]
#                 ]
#     for nmbr in win_move:
#         if nmbr[0] in move_joueur and nmbr[1] in move_joueur and nmbr[
#             2] in move_joueur:  # si les nombres dans la liste win_move sont dans la liste move_joueur
#             print("the player won !!")
#             game = 1
#             break
#         elif nmbr[0] in move_pc and nmbr[1] in move_pc and nmbr[2] in move_pc:
#             print("the pc won booooo")
#             game = 1
#             break
#         elif len(case_utiliser) == 9:
#             print("personne n'a gagner")
#             game = 1
#             break
#         else:
#             pass
#
#
# def draw_move():
#     while True:
#         rando = randrange(1, 9)
#         if rando not in case_utiliser:
#             case_utiliser.append(rando)
#             move_pc.append(rando)
#             valeur_jeu[rando] = "x"
#             print("The pc played the case : ", rando)
#             break
#
#
# while True:
#     if game == 1:
#         break
#     else:
#         display_board()
#         enter_move()
#         victory_for()
#         draw_move()
#         victory_for()
#         if game == 1:
#             break
#


# def nbr_vie(naissance):
#     naissance = list(naissance) #on transforme le nombre en liste
#     naissance = [int(i) for i in naissance] #on transforme chaque chiffre de la liste en int
#     print(naissance)
#     naissance = sum(naissance) #on additionne chaque chiffre de la liste
#     print(naissance)
#     if naissance < 10: #on vérifie si le nombre est inférieur a 10
#         print(naissance)
#     else:
#         nbr_vie(str(naissance)) #si ce n'est pas le cas on rappelle la fonction avec le nouveau nombre
#
#
# naissance = (input("quelle est votre date de naissance ? YEAR, MONTH, DAY : ")) #on demande la date de naissance
# nbr_vie(naissance) #on appelle la fonction


# def remove_accents(input_str):
#     accents = {'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o', 'û': 'u', 'ü': 'u'}
#     trans_table = str.maketrans(accents)
#     return input_str.translate(trans_table)
#
# dico = { #création du dictionnaire
#         'a' : 0,
#         'b' : 0,
#         'c' : 0,
#         'd' : 0,
#         'e' : 0,
#         'f' : 0,
#         'g' : 0,
#         'h' : 0,
#         'i' : 0,
#         'j' : 0,
#         'k' : 0,
#         'l' : 0,
#         'm' : 0,
#         'n' : 0,
#         'o' : 0,
#         'p' : 0,
#         'q' : 0,
#         'r' : 0,
#         's' : 0,
#         't' : 0,
#         'u' : 0,
#         'v' : 0,
#         'w' : 0,
#         'x' : 0,
#         'y' : 0,
#         'z' : 0,
#         }
#
# nom = input("quelle fichier? : ")
# with open(nom + ".txt", "r") as stream: #on ouvre le fichier texte
#          stream = stream.read()
#          stream= stream.lower().replace(" ", "")
#          stream = remove_accents(stream)
#          stream = list(stream) #on transforme le texte en liste
#          for ch in stream: #on entre dans la boucle pour chaque lettre
#                 if ch not in dico: #on vérifie si la lettre est dans le dictionnaire
#                         stream.remove(ch) #si ce n'est pas le cas on la supprime
#                 else: dico[ch] = dico[ch]+ 1 #sinon on ajoute 1 a la valeur de la lettre dans le dictionnaire (on compte le nombre de fois qu'elle apparait)
#          dico = sorted(dico.items(), key=lambda item: item[1], reverse=True) #on trie le dictionnaire par ordre croissant
#          dico = dict(dico)
#          for key, value in dico.items(): #on entre dans la boucle pour chaque lettre
#                 print(key, "->", value, "fois") #on affiche la lettre et le nombre de fois qu'elle apparait
# print("ce fichier n'existe pas")

# def moyenne_note(stream):
#     dico = {}
#     for line in stream: #on entre dans la boucle pour chaque ligne du fichier
#         line = line.split() #on transforme la ligne en liste
#         line[2] = float(line[2].replace(",", ".")) #on remplace la virgule par un point pour pouvoir transformer la note en float
#         name = line[0] + " " + line[1] #on crée une variable qui contient le nom et le prénom
#         if name not in dico: #on vérifie si le nom est dans le dictionnaire
#             dico[name] = [line[2], 1] #si ce n'est pas le cas on ajoute le nom et la note dans le dictionnaire
#         else:
#             dico[name]= [dico[name][0] + line[2], dico[name][1] + 1] #sinon on ajoute la note a la note déjà existante et on ajoute 1 au nombre de note
#     for key, value in dico.items(): #on entre dans la boucle pour chaque nom
#         print(key, "->", value[0]/value[1]) #on affiche le nom et la moyenne des notes
#
# def question():
#     try:
#         fichier = input("quelle est le nom du fichier ?")
#         with open(fichier + ".txt", "r") as stream:
#             moyenne_note(stream)
#     except:
#         print("ce fichier n'existe pas")
#         question()
#
# question()
#
# descriptions = {
#     "grappin": "Parfait pour escalader les gratte-ciel de Gotham ou attraper un sandwich dans le frigo à distance.",
#     "batarang": "Idéal pour désarmer les méchants, ou couper la pizza les vendredis soirs.",
#     "batmobile": "Le moyen de transport le plus cool et le moins discret pour naviguer dans Gotham. Attention aux bouchons !"
# }
#
#
# def analyser_gadget(nom_gadget):
#     if nom_gadget in descriptions: # Si le gadget est dans le dictionnaire
#         return descriptions[nom_gadget] # On retourne la description
#     else:
#         return "Gadget inconnu. Alfred, on a du travail !" # Sinon on retourne un message d'erreur
#
#
# def count_gadgets(file):  # Fonction pour compter les occurences
#     occurences = {}  # Initialisation d'un dictionnaire tampon
#     with open(file, 'r') as registre:  # Ouverture du fichier
#         bat_gadgets = registre.readlines()  # Lecture du fichier
#         i = 0
#     for element in bat_gadgets:
#         bat_gadgets[i] = element.rstrip("\n").lower()
#         i += 1
#     for line in bat_gadgets: # Pour chaque ligne du fichier
#         if line == "jokerbox" or line == "JokerBox":
#             pass
#         elif line in occurences: # Si la ligne est dans le dictionnaire
#             occurences[line] += 1 # On ajoute 1 à la valeur
#         else:
#             occurences[line] = 1 # Sinon on crée une nouvelle entrée dans le dictionnaire
#     return occurences
# def bat_signal():
#     answer = ""
#     while answer != "quit":
#         answer = input("Avez vous besoin de batman ? si oui tapez oui; si non tapez non; pour quitter ce menu taper quit : ")
#         if answer == "oui":
#             print("Batman est en route !")
#         elif answer == "non":
#             print("Gotham est en sécurité pour le moment.")
#         elif answer == "quit":
#             print("Batman prend une pause-café.")
#         else:
#             print("Je ne comprends pas votre demande, veuillez réessayer.")
#     return
#
# def ajouter_gadget(nom_gadget, description):
#     if nom_gadget not in descriptions:
#         descriptions[nom_gadget] = description
#     elif nom_gadget in descriptions:
#         print("Ce gadget se situe déja la :( ")
#     for key, value in descriptions.items():
#         print(key, "->", value)
# def supprimer_gadget(nom_gadget):
#     if nom_gadget in descriptions:
#         del descriptions[nom_gadget]
#     elif nom_gadget not in descriptions:
#         print("nous ne parvenons pas a trouver et supprimer",nom_gadget)
#     for key, value in descriptions.items():
#         print(key, "->", value)
# def modifier_gadget(nom_gadget, nouvelle_description):
#     if nom_gadget in descriptions:
#         descriptions[nom_gadget] = nouvelle_description
#         for key, value in descriptions.items():
#             print(key, "->", value)
#     elif nom_gadget not in descriptions:
#         question = input("Ce gadget ne se situe pas dans la liste, voulez vous l'ajouter ? oui/non : ")
#         if question == "oui":
#             ajouter_gadget(nom_gadget, nouvelle_description)
#         elif question == "non":
#             print("pas de problème !")
#         else:
#             print("vous me posez une colle..")
# def afficher_gadgets():
#     for element in descriptions:
#         print(element,':',descriptions[element])
#
# while True:
#     print("""
#     1) analyser gadget
#     2) compter gadget
#     3) bat signal
#     4) ajouter un gadget
#     5) supprimer un gadget
#     6) modifier un gadget
#     7) afficher tout les gadgets
#         """)
#     menu = input("Que voulez vous faire ? : ")
#     if menu == "1":
#         analyser_gadget(input("Quel gadget voulez vous analyser ? : "))
#     elif menu == "2":
#         count_gadgets(input("Quel est le nom du fichier ? : "))
#     elif menu == "3":
#         bat_signal()
#     elif menu == "4":
#         ajouter_gadget(input("Quel gadget voulez vous ajouter ? : "), input("Quel est la description de ce gadget ? : "))
#     elif menu == "5":
#         supprimer_gadget(input("Quel gadget voulez vous supprimer ? : "))
#     elif menu == "6":
#         modifier_gadget(input("Quel gadget voulez vous modifier ? : "), input("Quel est la nouvelle description de ce gadget ? : "))
#     elif menu == "7":
#         afficher_gadgets()
#     else:
#         print("ce choix n'est pas valide")

def vigenere(c, cle):
    """
        La fonction d'encodage se base sur :
        c : le message à chiffrer sous forme de chaine de caractères
        cle : la clé à utiliser sous forme de chaine de caractères
        Elle retourne le message chiffré sous forme de chaine de caractères
    """
    indice_cle = 0
    msg_code = ""

    for i in range(0, len(c)):
        if 'A' <= c[i] <= 'Z':
            msg_code += chr((((ord(c[i]) - ord('A')) + (ord(cle[indice_cle]) - ord('A'))) % 26) + ord('A'))
            indice_cle = (indice_cle + 1) % len(cle)
        else:
            msg_code += chr((((ord(c[i]) - ord('a')) + (ord(cle[indice_cle]) - ord('a'))) % 26) + ord('a'))
            indice_cle = (indice_cle + 1) % len(cle)
    return msg_code



print(vigenere('bonjour', 'python'))

def vigenere(c, clé):
    indice_clé = 0
    msg_code = ""
    for i in range(0, len(c)):
        if "A" < c[i] < "z"
            msg_code += chr((((ord(c[i]) - ord('A')) + (ord(cle[indice_clé]) - ord('A'))) % 26) + ord('A'))
            indice_clé = (indice_clé + 1) % len(cle)

