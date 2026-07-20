import unittest
from abc import ABC, abstractmethod
from unittest.mock import patch


class physique(ABC):
    def __init__(self):
        self._nom = str
        self._ports = list

    @abstractmethod
    def affichage(self):
        pass

    @abstractmethod
    def Prendre_initiative(self):
        pass

class CapteurThermique(physique):
    def __init__(self, nom, port):
        super.__init__(self, nom, port)
    

def lire_temperature():
 """Lecture de la température depuis un capteur (en °C)"""
 pass # à implémenter avec le vrai capteur
def controle_ventilation():
    temperature = lire_temperature()
    if temperature > 35:
        return "VENTILATEUR ON"
    else:
        return "VENTILATEUR OFF"


#----------------------------------------------------------------------------------------------------------
#tests

class TestControleVentilation(unittest.TestCase):
    @patch('__main__.lire_temperature')
    def test_ventilation_active(self, mock_lire_temperature):
        mock_lire_temperature.return_value = 37
        result = controle_ventilation()
        self.assertEqual(result, "VENTILATEUR ON")

    @patch('__main__.lire_temperature')
    def test_ventilation_inactive(self, mock_lire_temperature):
        mock_lire_temperature.return_value = 30
        result = controle_ventilation()
        self.assertEqual(result, "VENTILATEUR OFF")


if __name__ == "__main__":
    unittest.main() 
