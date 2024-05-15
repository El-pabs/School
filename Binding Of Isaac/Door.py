import pygame

Longueur = 150
Hauteur = 500

class Door(pygame.sprite.Sprite):
    def __init__(self, door_direction):
        super().__init__()
        self.direction = door_direction
        self.image = pygame.Surface((500, 150))
        self.image.fill((255, 0, 0))
        self.rect = self.image.get_rect()
        self.set_position(self.direction)

    def set_position(self, door_direction):
        if door_direction == "nord":
            self.rect.center = (Longueur / 2, 0)
        elif door_direction == "sud":
            self.rect.center = (Longueur / 2, Hauteur)
        elif door_direction == "ouest":
            self.rect.center = (0, Hauteur / 2)
        elif door_direction == "est":
            self.rect.center = (Longueur, Hauteur / 2)


