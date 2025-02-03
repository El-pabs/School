
# while True :
#     print("bloqé")
#     a = input("tente")
#     if a == "chup":
#         print("gg")
#         break

#------------------------------------------------------------------------

# numbers = [1,2,5,87,95,3]
# print(numbers)
# numbers[0] = 100 #changement de la valeur de l'index 0
# print(numbers)

#------------------------------------------------

# numbers = [1,2,5,87,95,3]
# print(len(numbers)) #donne la longeur de la liste
# del numbers[1]  #supprime un element a l'index donné
# print (numbers)

# ---------------------------------------------------

#chapeau = [1,2,3,4,5] #liste de maison
#chapeau [2] = int(input("donne moi le numéro a remplacer"  )) #récupère un numéro pour remplacer celui dors et déja existant en index 2 (dans ce cas le numéro 3)
#del chapeau [-1] #supprime la valeur a la dernière position
#print(len(chapeau)) #affiche la longeur de la liste
#print(chapeau)

# ------------------------------------------------

#groupe = [] #on créer une liste vide
#groupe.append("Johan le preter")
#groupe.append("Denis seins doux")
#groupe.append("Yoan l\'imprononsable") #pour les 3 ici nous ajoutons dans notre liste leur noms
#print (groupe)
#for i in groupe: #on entre une boucle
#    joa= input("voulez vous ajouter joakim synagogue ?" )
#    dav = input("voulez vous ajouter david Art nouveau" ) #on demande si il souhaite les ajouté ou non
#    if joa == "yes":
#        groupe.append("Joakim synagogue") #si l'user a répondu oui on ajoute sinon on passe au prochain
#    if dav =="yes":
#        groupe.append("David Art nouveau")
#    print(groupe)
#    break #on sort de la boucle for
#del groupe [-1] #on supprime le dernier membre
#del groupe [1]
#groupe.insert(0,"Erwin le Schmet")
#print(groupe)

#---------------------------------------------------------

#a = [1,2,3]
#b = [7,8,9]
#
#a,b=b,a #ca nous permet d'inverser 2 liste entre elles
#print(a,b)

# --------------------------------------------------------

#liste = [1,2,4,4,1,4,2,3,6,2,9] #liste avec info
#listecop = [] #création de la liste tempon
#print(liste)
#for element in liste:   #je dis de faire la boucle autant de fois qu'il y a d'élément
#    if not (element in listecop):    #on dit que Si il n'y a pas (element dans listecop)  --> ca permet d'éviter de copier si il est déja la
#        listecop.append(element)   #on ajoute l'élement dans listecop
#print(listecop)

# --------------------------------------------------

#nom = ["jean-michel", "paul", "vanessa", "maximilien"]
#cak = []
#for i in nom:
#    tempo = i + str(len(i))
#    cak.append(tempo)
#print(cak)

# ---------------------------------------------------

#liste = [1, 3, 5, 7, 8, 10, 12] #création d'une liste contenant les mois qui possèdent 31 jours
#
#def is_it_leap(year):
#    return year % 400 == 0 and year % 100 == 0 or year % 4 == 0 and year % 100 != 0
#
#def what_month(year, month):  # création de la fonction
#    if month > 12 or month < 1: #vérification que le mois est valide
#        print("mois invalide")
#        return
#    if month == 2 and is_it_leap(year):  #vérification que le mois de février contient 29 jours en utilisant la fonction pour vérifier si année bissextile
#        print("this month is 29 days long")
#    elif month == 2:
#        print("this month is 28 days long")
#    elif month in liste:                    #si le mois se situe dans la liste il possède 31 jours sinon c'est 30
#        print("this month is 31 days long")
#    else:
#        print("this month is 30 days long")
#what_month(int(input("what year do you want :")), int(input("what month do you want :")))

#----------------------------------------------------------

#def is_prime(num):   #création de la fonction
#    liste =[]
#    for i in range (2, num+1):           #on donne a i chaque valeur entre 2 et mon nombre
#         if i==num:                       #on regarde si i vaut mon nombre de base et si il n'y a eu aucun autre nombre qui l'a divisé grâce à a 0
#             if len(liste)<1:           #si ma liste est plus petite que 1 (donc 0) mon nombre n'a pas pu etre divisé une seul fois
#                print("the number",i, "is prime")
#                break
#             elif len(liste)>=1:         #si mon nombre n'a pas été divisé que par lui meme alors on imprime la liste pour montrer a cause de quelle nombre
#                print("this number is not prime because of all the following numbers :", liste)
#         if num%i==0:                  #si mon nombre est divisible entièrement par un nombre alors il n'est pas premier (sauf lui même)
#             liste.append(i)            #on place la valeur dans la liste car il divise entièrement notre numéro
#         else:
#             None
#is_prime(int(input('le nombre chef')))         #appel de la fonction

#------------------------------------------------------------

#def liters_100km_to_miles_gallon(liters):
#    return 235.214583 / liters
#
#def miles_gallon_to_liters_100km(miles):
#    return 235.214583 / miles
#
#print(liters_100km_to_miles_gallon(3.9))
#print(liters_100km_to_miles_gallon(7.5))
#print(liters_100km_to_miles_gallon(10.))
#print(miles_gallon_to_liters_100km(60.3))
#print(miles_gallon_to_liters_100km(31.4))
#print(miles_gallon_to_liters_100km(23.5))

#------------------------------------------------

# def factorielle(num):
#     if num <= 0:                #on gère les exeption
#         return "ntm sale fdp"
#     if num==1:                  #on verifie si c la fin
#         return 1
#     else:
#         return num * factorielle(num-1) #on multiplie le num (resultat) avec le numero -1
#
# print(factorielle(int(input("quelle factorisation ? "))))

# def fib(n):
#     if n <= 1:
#         return n
#     return fib(n-1) + fib(n-2)     #on additionne le nombre -1 avec le nombre -2 et on le fait en appellant la fonction
#
# print(fib(int(input("quelle numero ? :"))))

#-------------------------------------------------------------

# def monsplit(strin): #fonction qui permet de séparer les mots d'une phrase
#     lister = [] #création de la liste
#     tempor = "" #création d'une variable temporaire
#     for lettre in strin: #on entre dans la boucle pour chaque lettre
#         if lettre == " ": #si la lettre est un espace on ajoute le mot dans la liste et on réinitialise la variable temporaire
#             lister.append(tempor)
#             tempor = " "
#         else: #sinon on ajoute la lettre a la variable temporaire
#             tempor += lettre
#     lister.append(tempor) #on ajoute le dernier mot
#     return lister
#
# print(monsplit(input("quel phrase ? :")))

#-------------------------------------------------------------

# dico = {
#     0: ['###', '# #', '# #', '# #', '###'],
#     1: [' # ', ' # ', ' # ', ' # ', ' # '],
#     2: ['###', '  #', '###', '#  ', '###'],
#     3: ['###', '  #', '###', '  #', '###'],
#     4: ['# #', '# #', '###', '  #', '  #'],
#     5: ['###', '#  ', '###', '  #', '###'],
#     6: ['###', '#  ', '###', '# #', '###'],
#     7: ['###', '  #', '  #', '  #', '  #'],
#     8: ['###', '# #', '###', '# #', '###'],
#     9: ['###', '# #', '###', '  #', '###']
#         }
#
# while True:
#     try:
#         number = int(input("quel nombre voulez vous afficher ? : "))
#         for colone in range(5): # on entre dans la boucle pour chaque ligne
#             for nombre in str(number): # on entre dans la boucle pour chaque chiffre
#                 print(dico[int(nombre)][colone], end=" ") # on affiche la valeur de la ligne i du chiffre j
#             print() # on passe a la ligne
#     except:
#         print("ce n'est pas un nombre")

#-------------------------------------------------------------

# tempor = [] #création de la liste temporaire
# decalage = 0 #création de la variable decalage
# def cryptage(decale,decalage):
#     alphabet_min = "abcdefghijklmnopqrstuvwxyz"         #création de l'alphabet minuscule
#     alphabet_maj = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"          #création de l'alphabet majuscule
#     tempo = decale.split()                               #on sépare les mots de la phrase
#     for mots in tempo:                                  #on entre dans la boucle pour chaque mot
#         a = ""                                           #on créée la variable a
#         for letter in mots:                             #on entre dans la boucle pour chaque lettre
#             if letter.isdigit() or letter == " ":       #on vérifie si la lettre est un nombre ou un espace
#                 a = a + letter
#                 pass                                    #si c'est le cas on l'ajoute a la variable a et on passe a la lettre suivante
#             if letter in alphabet_min:                #on vérifie si la lettre est dans l'alphabet minuscule
#                 if int(alphabet_min.find(letter) + decalage) >25: #on vérifie si l'index est supérieur a 25
#                     a = a + (alphabet_min[alphabet_min.find(letter) + decalage - 26]) #si c'est le cas on ajoute la lettre a la variable a en prenant la lettre a l'index -26
#                 else:
#                     a = a + (alphabet_min[alphabet_min.find(letter) + decalage]) #sinon on ajoute la lettre a la variable a en prenant la lettre a l'index + le decalage
#             elif letter in alphabet_maj:
#                 if int(alphabet_maj.find(letter) + decalage)>25: #même chose que pour les minuscules
#                     a = a + (alphabet_maj[alphabet_maj.find(letter) + decalage - 26]) #même chose que pour les minuscules
#                 else :
#                     a = a + (alphabet_maj[alphabet_maj.find(letter) + decalage]) #même chose que pour les minuscules
#         print (a)
#
# def ask():
#     global decalage
#     try:
#         decalage = int(input("decalage ? : ")) #on demande le décalage
#     except:
#         print("ce n'est pas un nombre, recommencez") #on gère les exeptions
#         ask()
#     while decalage >= 26: #on vérifie que le décalage est inférieur a 26
#         decalage -= 26 #on soustrait 26 au décalage
#     cryptage(decale,decalage) #on appelle la fonction cryptage
#
# decale = input("quel mot voulez vous crypter ? : ") #on demande le mot a crypter
# if decalage == 0: #on vérifie si le décalage est déja défini
#     ask() #si ce n'est pas le cas on appelle la fonction ask

#-------------------------------------------------------------
#
# def palindrome(mots):
#     mots.islower() #on met tout en minuscule
#     mots.strip() #on supprime les espaces
#     mots = mots.replace(" ","") #on remplace les espaces par rien
#     if mots == mots[::-1]: #on vérifie si le mot est égal a lui même inversé
#         print(mots, "est un palindrome")
#     else:
#         print(mots, "n'est pas un palindrome")
#
# try:
#     palindrome(str(input("quel mot voulez vous vérifier ? : "))) #on demande le mot a vérifier
# except:
#     print("ce n'est pas un mot")

#-------------------------------------------------------------

# def annagrame():
#     mots1 = input("quel mot voulez vous vérifier ? : ") #on demande le mot a vérifier
#     mots2 = input("quel mot voulez vous vérifier ? : ") #on demande le mot a vérifier
#     mots1 = mots1.replace(" ","") #on remplace les espaces par rien
#     mots2 = mots2.replace(" ","") #on remplace les espaces par rien
#     mots1 = list(mots1) #on transforme le mot en liste
#     mots2 = list(mots2) #on transforme le mot en liste
#     if len(mots1) == len(mots2):
#         mots1.sort()
#         mots2.sort()
#         if mots1 == mots2:
#             print("ce sont des annagrammes")
#         else:
#             print("ce ne sont pas des annagrammes")
#     else: print("ce ne sont pas des annagrammes")
#
# annagrame()

#-------------------------------------------------------------

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
# naissance = input("quelle est votre jour de naissance ? : ") , input("quelle est votre mois de naissance ? : ") , input("quelle est votre année de naissance ? : ") #on demande la date de naissance
# nbr_vie(naissance) #on appelle la fonction

#-------------------------------------------------------------


# def dedans(chaine, chaine1):
#     for letter in chaine:
#         if letter not in chaine1:
#             print(letter, "NOT IN")
#         elif letter in chaine1:
#             print(letter, 'inside')
#
# dedans(str(input("quelle chaine ? : ")), str(input("quelle chaine ? : ")))

#-------------------------------------------------------------

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
# try:
#         nom = input("quelle fichier? : ")
#         with open(nom + ".txt", "r") as stream: #on ouvre le fichier texte
# except: #on gère les exeptions
#         print("ce fichier n'existe pas")

#                 stream = stream.read()
#                 stream= stream.lower().replace(" ", "")
#                 stream = remove_accents(stream)
#                 stream = list(stream) #on transforme le texte en liste
#                 for ch in stream: #on entre dans la boucle pour chaque lettre
#                         if ch not in dico: #on vérifie si la lettre est dans le dictionnaire
#                                 stream.remove(ch) #si ce n'est pas le cas on la supprime
#                         else: dico[ch] = dico[ch]+ 1 #sinon on ajoute 1 a la valeur de la lettre dans le dictionnaire (on compte le nombre de fois qu'elle apparait)
#                 dico = sorted(dico.items(), key=lambda item: item[1], reverse=True) #on trie le dictionnaire par ordre croissant
#                 dico = dict(dico) #on le retransforme en dico
#                 for key, value in dico.items(): #on entre dans la boucle pour chaque lettre
#                         print(key, "->", value, "fois") #on affiche la lettre et le nombre de fois qu'elle apparait
#
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



