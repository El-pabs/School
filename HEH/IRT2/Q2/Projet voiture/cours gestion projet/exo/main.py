import unittest
import threading

lock = threading.Lock()

class ICompte ():
    def __init__(self):
        pass

    def depot(self, montant: float):
        pass

    def retrait(self, montant: float):
        pass

    def afficher(self) -> str:
        pass


class CompteBancaire(ICompte):
    def __init__(self, titulaire: str, solde: float=0):
        self._titulaire = titulaire
        self._solde = solde
    
    with lock:
        def depot(self, montant: float):
            if montant > 0:
                self._solde += montant
            else:
                raise ValueError("Le montant doit être positif")
        
        def retrait(self, montant):
            try:
                if montant > self._solde:
                    raise ValueError("Fonds insuffisants")
                else:
                    self._solde -= montant
                    print ("Retrait effectué avec succès")
            except ValueError as e:
                print (e)

    def affichage(self):
        return f"Titulaire: {self._titulaire}, Solde: {self._solde} euro"
        
    @property
    def titulaire(self):
        return self._titulaire
    
    @property
    def solde(self):
        return self._solde
    
    @solde.setter
    def solde(self, montant):
        if montant >= 0:
            self._solde = montant
        else:
            raise ValueError("Le solde doit être positif")


class CompteEpargne(CompteBancaire):
    def __init__(self, titulaire, solde = 0):
        super().__init__(titulaire, solde)
        self._taux_interet = 0.02
    
    def ajouter_interets(self):
        interets = self._solde * self._taux_interet
        self.depot(interets)
        print(f"Intérêts ajoutés: {interets} €")

class Client():
    def __init__(self, nom: str, comptes : list):
        self.__nom = nom
        self.__comptes = comptes
    
    def ajouter_compte(self, compte):
        self.__comptes.append(compte)
    
    def resume_comptes(self) -> str:
        return "\n".join([str(compte) for compte in self.__comptes])
        
    
    @property
    def nom(self):
        return self.__nom
    
    @property
    def comptes(self):
        return self.__comptes
    
    @comptes.setter
    def comptes(self, comptes: list):
        self.__comptes = comptes

class Test_fonction_compte_bancaire(unittest.TestCase):
    def setUp(self):
        self.client = Client("Mavio", [])
        self.compte = CompteBancaire("Mavio", 1000)

    def ajout_compte(self):
        self.client.ajouter_compte(self.compte)
        self.assertIn(self.compte, self.client.comptes)
    
    def depot_sur_compte(self):
        self.compte.depot(500)
        self.assertEqual(self.compte.solde, 1500)
    
    def retrait_sur_compte(self):
        self.compte.retrait(200)
        self.assertEqual(self.compte.solde, 800)

class Test_fonction_compte_epargne(unittest.TestCase):
    def setUp(self):
        self.client = Client("Mavio", [])
        self.compte = CompteEpargne("Mavio", 2000)
    
    def ajout_compte(self):
        self.client.ajouter_compte(self.compte)
        self.assertIn(self.compte, self.client.comptes)
    
    def appliquer_interet(self):
        self.compte.ajouter_interets()
        self.assertEqual(self.compte.solde, 2040)

class Test_affichage(unittest.TestCase):
    def setUp(self):
        self.client = Client("Mavio", [])
        self.compte = CompteBancaire("Mavio", 1000)
    
    def test_affichage(self):
        self.client.ajouter_compte(self.compte)
        self.assertEqual(self.compte.affichage(), "Titulaire: Mavio, Solde: 1000 euro")

def effectuer_depots(compte, nombre_depots, montant):
    for _ in range(nombre_depots):
        compte.depot(montant)

if __name__ == "__main__":
    compte = CompteBancaire("Mavio", 1000)
    nombre_threads = 5
    nombre_depots = 1000
    montant_par_depot = 10

    threads = []
    for _ in range(nombre_threads):
        thread = threading.Thread(target=effectuer_depots, args=(compte, nombre_depots, montant_par_depot))
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()

    solde_attendu = 1000 + (nombre_threads * nombre_depots * montant_par_depot)
    print(f"Solde attendu : {solde_attendu} €")
    print(f"Solde réel : {compte.solde} €")
