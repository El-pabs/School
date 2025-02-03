"tri"
liste=[2,6,4,5,8,9,7,3]
def triabulle(liste):
    for i in range(len(liste)):
        for j in range(0, len(liste)-i-1):
            if liste[j] > liste[j+1]:
                temp = liste[j]               #{ autre méthode
                liste[j] = liste[j+1]         #{ liste[j],liste[j+1] = liste[j+1],liste[j]
                liste[j+1] = temp             #{
    return liste

print(triabulle(liste))

def triParInsertion(liste):
    for i in range(1, len(liste)):
        temp = liste[i]
        j = i-1
        while j>=0 and temp< liste[j]:
            liste[j+1] = liste[j]
            j = j-1  # ou j-=1
        liste[j+1] = temp
    return liste

print(triParInsertion(liste))

def triParFusion(liste):
    if len(liste) > 1:
        milieu = len(liste)//2     # exemple:  11//2= 5  (car 11/2=5.5) on retire ce qu'il y a derriere la ,
        gauche=liste[:milieu]      #on commence une nouvelle liste du début jusqu'au milieu (on ne prend pas la valeur avec l'index du milieu)
        droite=liste[milieu:]      #on commence une nouvelle liste du milieu jusqu'a la fin (on prend la valeur de l'index du milieu)
        triParFusion(gauche)
        triParFusion(droite)
        i,j,k=0,0,0

        while i < len(gauche) and j < len(droite):
            if gauche[i] < droite[j]:
                liste[k] = gauche[i]
                i = i+1  # i+=1
            else:
                liste[k] = droite[j]
                j = j+1  # j+=1
            k = k+1  # k+=1

        while i < len(gauche):
            liste[k] = gauche[i]
            i = i+1  # i+=1
            k = k+1  # k+=1
        while j < len(droite):
            liste[k] = droite[j]
            j = j+1  # j+=1
            k = k+1  # k+=1
    return liste

print(triParFusion(liste))

def parti(debut, fin, liste):
    pivot =liste[fin]
    i = debut-1

    for j in range(debut, fin):
        if liste[j] <= pivot:
            i = i+1  # i+=1
            liste[j], liste[i]= liste[i], liste[j]  # inversion des valeur comme pour a,b=b,a ||a obtiens la valeur de b et inversement sans variable intermediaire
    liste[i+1], liste[fin] = liste[fin], liste[i+1]  # idem

    return i+1
def triRapide(debut, fin, liste):
    if (debut < fin):
         p = parti(debut, fin, liste)
         triRapide(debut, p-1 , liste)
         triRapide(p+1, fin, liste)
    return liste

print(triRapide(0,len(liste)-1,liste))  # ne pas oublier que c'est la longueur de la liste moins 1 pour la fin