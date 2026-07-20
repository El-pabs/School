def ajouclient():
    nom = input("Entrez le nom : ")
    prenom = input("Entrez le prénom : ")
    mail = nom[:3] + prenom[0]
    salaire = input("Entrez le salaire : ")
    fs = open("personnel", "a")
    fs.write(nom + "#" + prenom + "#" + mail + "@gmail.com" + "#" + salaire + "\n")
    fs.close()
    print("Personne ajoutée avec succès !")


def moyennesalaire():
    liste = []
    fs = open("personnel", 'r')
    rows = fs.readlines()  # met toutes les lignes du fichier dans une liste
    for salaire in rows:
        liste.append(int(salaire.strip().split('#')[
                             -1]))  # ajoute à la liste crée plus haut les salaires en int() en supprimant tous les \ en séparant chaque mots séparer par un # et en prenant le dernier élément

    moyenne = sum(liste) / len(liste)  # fait la moyenne des salaires
    print("La moyenne des salaires est de ", moyenne, "euros")


def trisalaire():
    liste = []
    fs = open("personnel", 'r')
    rows = fs.readlines()
    for salaire in rows:
        liste.append(int(salaire.strip().split('#')[-1]))

    for i in range(1, len(liste)):
        temp = liste[i]
        j = i - 1
        while j >= 0 and temp < liste[j]:
            liste[j + 1] = liste[j]
            j -= 1
            liste[j + 1] = temp
    print(liste)


def trinom():
    liste = []
    fs = open("personnel", 'r')
    rows = fs.readlines()
    for salaire in rows:
        liste.append(salaire.strip().split('#')[0])

    for i in range(1, len(liste)):
        temp = liste[i]
        j = i - 1
        while j >= 0 and temp < liste[j]:
            liste[j + 1] = liste[j]
            j -= 1
            liste[j + 1] = temp
    print(liste)


def triprenom():
    liste = []
    fs = open("personnel", 'r')
    rows = fs.readlines()
    for salaire in rows:
        liste.append(salaire.strip().split('#')[1])

    for i in range(1, len(liste)):
        temp = liste[i]
        j = i - 1
        while j >= 0 and temp < liste[j]:
            liste[j + 1] = liste[j]
            j -= 1
            liste[j + 1] = temp
    print(liste)


def triemail():
    liste = []
    fs = open("personnel", 'r')
    rows = fs.readlines()
    for salaire in rows:
        liste.append(salaire.strip().split('#')[2])

    for i in range(1, len(liste)):
        temp = liste[i]
        j = i - 1
        while j >= 0 and temp < liste[j]:
            liste[j + 1] = liste[j]
            j -= 1
            liste[j + 1] = temp
    print(liste)


def search(key):
    with open('personnel', 'r') as file:
        for row in file:
            if key in row.strip():
                print(row.strip().split('#'))
        return None


def nbremployer():
    fs = open("personnel", "r")
    print("Il y a", len(fs.readlines()), "employés")


def menu():
    print("1: ajouter une personne")
    print("2: afficher le nombre d'employer")
    print("3: Afficher la moyenne des salaire")
    print("4: Chercher une personne")
    print("5: Tri par salaire")
    print("6: Tri par nom")
    print("7: Tri par prenom")
    print("8: Tri par e-mail")
    print("9: Sortir")

    return input("Entrez votre choix : ")


while 1:
    choix = menu()
    if choix == "1":
        ajouclient()
    elif choix == "2":
        nbremployer()
    elif choix == "3":
        moyenneSalaire()
    elif choix == "4":
        search(input("Entrez le nom, le prénom, le salaire ou l'e-mail de la personne que vous cherchez : "))
    elif choix == "5":
        triSalaire()
    elif choix == "6":
        triNom()
    elif choix == "7":
        triPrenom()
    elif choix == "8":
        triEmail()
    elif choix == "9":
        print("Au revoir !")
        break
    else:
        print('Choix non valide, réessayer.')
