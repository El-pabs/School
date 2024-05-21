import pygame

class Tile(pygame.sprite.Sprite):
    """Classe qui réprésente les sprites d'une tile"""
    def __init__(self, material):
        super().__init__()
        self.material = material


        