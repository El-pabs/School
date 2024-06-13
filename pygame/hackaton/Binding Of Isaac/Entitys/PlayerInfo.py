import pygame



HAUTEUR, LARGEUR = 800, 800

class PlayerInfo(pygame.sprite.Sprite):
    def __init__(self, entity):
        super().__init__()
        self.entity = entity
        self.font = pygame.font.SysFont("Arial", 24)
        self.show_info = False
        self.update_image()

    def update_image(self):
        info_surface = pygame.Surface((200, 100))
        info_surface.fill((0, 0, 0))
        info = [
            f"Nom: {self.entity.name}",
            f"Vitesse: {self.entity.speed}",
            f"Force: {self.entity.strength_power}",
            f"Santé: {self.entity.health}/{self.entity.max_health}"
        ]
        for i, text in enumerate(info):
            text_render = self.font.render(text, True, (255, 255, 255))
            info_surface.blit(text_render, (10, 10 + i * 20))
        self.image = info_surface
        self.rect = self.image.get_rect(topright=(LARGEUR - 10, 10))

    def update(self):
        if self.show_info:
            self.update_image()
class PlayerInfoSprite(pygame.sprite.Sprite):
    def __init__(self, player_info):
        super().__init__()
        self.player_info = player_info

    def update(self):
        self.player_info.update()
        self.image = self.player_info.image
        self.rect = self.player_info.rect
