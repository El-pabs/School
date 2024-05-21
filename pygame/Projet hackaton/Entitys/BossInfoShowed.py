import pygame

HAUTEUR, LARGEUR = 800, 800

class BossInfoShowed(pygame.sprite.Sprite):
    def __init__(self, boss):
        super().__init__()
        self.boss = boss
        self.font = pygame.font.SysFont("Arial", 18)
        self.update_image()

    def update_image(self):
        info_surface = pygame.Surface((200, 50))
        info_surface.fill((0, 0, 0))
        info = [
            f"Nom: {self.boss.name}",
            f"Niveau: {self.boss.level}"
        ]
        for i, text in enumerate(info):
            text_render = self.font.render(text, True, (255, 255, 255))
            info_surface.blit(text_render, (10, 10 + i * 20)) #Je gère les positions des textes
        self.image = info_surface
        self.rect = self.image.get_rect(midbottom=self.boss.rect.midtop)

    def update(self):
        self.update_image()
