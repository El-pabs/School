import os

def find_txt_files(directory):
    file_paths = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.txt'):
                file_paths.append(os.path.join(root, file))
    return file_paths


def is_it_in(wordToFind):
    for path in find_txt_files("C:/Users/robin/Downloads/exam_test/fichiersTXT"):
        print (path)
        with open(path, "r", encoding="utf-8") as open_file:
            stopper = 0
            for line in open_file:
                if wordToFind in line and stopper == 0:
                    print(wordToFind, "is in", path)
                    stopper = 1
            if stopper == 0:
                print (wordToFind, "not in", path)


def lzw(string:str):
    dictionary = {chr(i):i for i in range(256)}
    compteur = 256
    chaine_actuelle =""
    données_comp = []

    for lettre in string: # Pour chaque lettre dans le mot
        chaine_addition = chaine_actuelle + lettre # On ajoute la lettre à la chaine actuelle
        if chaine_addition in dictionary: # Si la chaine additionnée est dans le dictionnaire
            chaine_actuelle = chaine_addition # On remplace la chaine actuelle par la chaine additionnée
        else: # Sinon
            dictionary[chaine_addition] = compteur # On ajoute la chaine additionnée au dictionnaire
            données_comp.append(dictionary[chaine_actuelle]) # On ajoute la valeur de la chaine actuelle à la liste
            compteur +=1 # On incrémente le compteur
            chaine_actuelle = lettre # On remplace la chaine actuelle par la lettre
    if chaine_actuelle: # Si la chaine actuelle n'est pas vide
            données_comp.append(dictionary[chaine_actuelle]) # On ajoute la valeur de la chaine actuelle à la liste

    données_comp=" ".join(map(str, données_comp))
    print(données_comp)



def tri_insertion():
    # Get all files with their sizes
    files = [(path, os.path.getsize(path)) for path in find_txt_files("fichiersTXT")]

    # Sort files by size using insertion sort in descending order
    for i in range(1, len(files)):
        key = files[i]
        j = i - 1
        while j >= 0 and key[1] > files[j][1]:  # Change here for descending order
            files[j + 1] = files[j]
            j -= 1
        files[j + 1] = key

        # Return sorted file paths along with their sizes
    for file in files:
        print(f"File: {file[0]}, Size: {file[1]} bytes")


def cbm_ou(wordToFind):
    wordFindeddico = {}
    for path in find_txt_files("C:/Users/robin/Downloads/exam_test/fichiersTXT"):
        with open(path, "r", encoding="utf-8") as open_file:
            for line in open_file:
                wordFindeddico[path] = wordFindeddico.get(path, 0) + line.count(wordToFind)
    for key in wordFindeddico:
        print(key, ':', "found" ,wordToFind, wordFindeddico[key], "times")


def cbm_en_tout(wordToFind):
    wordFindedCount = 0
    for path in find_txt_files("C:/Users/robin/Downloads/exam_test/fichiersTXT"):
        with open(path, "r", encoding="utf-8") as openFile:
            for line in openFile:
                wordFindedCount += line.count(wordToFind)
    print(wordFindedCount)




c = "fichiersTXT"


def vigenere(c, cle):
    indice_cle = 0
    msg_code = ""
    for i in range(0, len(c)):
        if 'A'< c[i] < 'Z':
            msg_code += chr((((ord(c[i])-ord("A"))+ (ord(cle[indice_cle]) - ord("A")))%26) + ord('A'))
            indice_cle = (indice_cle + 1) % len(cle)
    return msg_code




print(vigenere('BONJOUR', 'PYTHON'))


