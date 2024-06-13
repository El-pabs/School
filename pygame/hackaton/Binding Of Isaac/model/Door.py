import pygame

class Door(pygame.sprite.Sprite):
    """Classe qui réprésente les portes"""
    def init(self, door_direction):
        super().init()
        self.direction = door_direction
        self.image = pygame.Surface((75, 75))
        self.image.fill((255, 0, 0))
        self.rect = self.image.get_rect()
        self.set_position(self.direction)

    def set_position(self, longeur=1280 ,hauteur=720):
        if self.door_direction == "nord":
            self.rect.center = (longeur / 2, 0)
        elif self.door_direction == "sud":
            self.rect.center = (longeur / 2, hauteur)
        elif self.door_direction == "ouest":
            self.rect.center = (0, hauteur / 2)
        elif self.door_direction == "est":
            self.rect.center = (longeur, hauteur / 2)


