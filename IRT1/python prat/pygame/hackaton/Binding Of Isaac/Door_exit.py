import pygame
import random

width, height = 1280, 720

class ExitDoor(pygame.sprite.Sprite):
    '''
    Classe ExitDoor : Classe représentant la porte de sortie du niveau
    '''
    def __init__(self, position):
        super().__init__()
        self.image = pygame.image.load("assets/Graphics/exit_door.png")
        self.rect = self.image.get_rect()
        if position == "top":
            self.rect.center = (width // 2, 50)
        elif position == "bottom":
            self.rect.center = (width // 2, height - 50)
        elif position == "left":
            self.rect.center = (50, height // 2)
        elif position == "right":
            self.rect.center = (width -50, height // 2)

    def update(self):
        pass

    def draw(self, surface):
        surface.blit(self.image, self.rect)
